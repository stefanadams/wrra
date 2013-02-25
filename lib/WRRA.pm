package WRRA;
use Mojo::Base 'Mojolicious';
use Mojo::Util qw(camelize decamelize);
use File::Basename;

use Carp;
use WRRA::Controller;
use WRRA::Model;

use Switch;
use Data::Walk;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/../lib";

# This method will run once at server start
sub startup {
  my $self = shift;
  $self = $self->moniker('wrra');
  $Carp::Verbose = 1;
  $self->setup_plugins;
  $self->setup_model;
  $self->setup_routing;
  $self->setup_hooks;
}

sub setup_plugins {
  my $self = shift;

  my $basename = basename $0, '.pl';
  $self->plugin('Config',
    default => {
      year => $ENV{WRRA_YEAR},
      database => {
        type => ($ENV{WRRA_DBTYPE}||'mysql'),
        name => ($ENV{WRRA_DBNAME}||$basename),
        host => ($ENV{WRRA_DBHOST}||'localhost'),
        user => ($ENV{WRRA_DBUSER}||$basename),
        pass => ($ENV{WRRA_DBPASS}||$basename),
      },
    }
  );

  $self->controller_class('WRRA::Controller');

  $self->plugin('PODRenderer');  # Documentation browser under "/perldoc"
  #$self->plugin('ConsoleLogger');  # Only use on HTML docs
  $self->plugin('MyConfig');
  $self->plugin('TitleVersion');
  $self->plugin('WriteExcel');
  $self->plugin('HeaderCondition');
  $self->plugin('AutoComplete');
  $self->plugin('IsXHR');
  $self->plugin('JSON');
  $self->plugin('Parameters');
  #$self->plugin('I18N' => { default => 'en'});  # Helper "url_for" already exists, replacing

  # Add types for responding_to a specific accept type
  $self->types->type(jqgrid => 'x-application/jqgrid');
}

sub setup_routing {
  my $self = shift;
  my $r = $self->routes;

  # TODO Auto-find all Controllers
  #$r->namespaces(['WRRA::Controller', 'WRRA::Controller::Admin', 'WRRA::Controller::Admin::Manage']);
  $r->namespaces(['WRRA::Controller']);

  # Authentication conditions
  $r->add_condition(login => sub { $_[1]->auth_require_login });
  $r->add_condition(role  => sub { $_[1]->auth_require_role($_[3]) });

  # Shortcuts
  $r->add_shortcut(xhr => sub { shift->over(is_xhr=>shift||1) });

  # Normal route to controller
  $r->get('/')->to('user#index');
  $r->post('/' => sub { my $self = shift; $self->render_json($self->req->json); });
  $r->get('/bookmarks')->to(cb=>sub{shift->redirect_to('/admin/bookmarks')});

  my $api = $r->under('/api');

  my $ac = $api->under('/ac');
  foreach my $model ( qw/city donor item stockitem advertisement advertiser item_stockitem bellitem ad/ ) {
    $ac->get("/$model")->xhr->to("api#auto_complete", mv=>"ac_$model")->name("ac_$model");
  }
  my $bs = $api->under('/bs');
  foreach my $model ( qw/rotarians/ ) {
    $bs->get("/$model")->xhr->to("api#build_select", mv=>"bs_$model")->name("bs_$model");
  }
  my $item_number = $api->get('/item_number')->xhr->to('api#item_number', mv=>'item_number')->name('item_number');

  my $admin = $r->under('/admin');

  foreach my $model ( qw/rotarians donors stockitems items ads bellitems bidders bids/ ) {
    my $r1 = $admin->under("/$model");
    $r1->post("/create")->xhr->to("crud#create", m=>$model, v=>'jqgrid')->name('create_'.$model);
    $r1->post('/')->xhr->to('crud#read', m=>$model, v=>'jqgrid');
    #$r1->get('/', format=>[qw/xls/])->to('crud#read', m=>$model, v=>'jqgrid'); # Why won't this work?
    $admin->get("/$model.xls")->to('crud#read', m=>$model, v=>'jqgrid', format=>'xls'); # Can only download via a non-xhr get request
    $r1->post("/update")->xhr->to("crud#update", m=>$model, v=>'jqgrid')->name('update_'.$model);
    $r1->delete("/delete")->xhr->to("crud#delete", m=>$model, v=>'jqgrid')->name('delete_'.$model);
  }
  $admin->under('/donors')->post('/items')->xhr->to('crud#read', m=>'donor_items', v=>'jqgrid')->name('donor_items');
  $admin->get('/sequence')->xhr->to('crud#read', m=>'seq_items', v=>'seq_items', start=>$self->app->config('start'))->name('seq_items');
  $admin->get('/sequence/:n')->xhr->to('crud#read', m=>'seq_items', v=>'seq_items', start=>$self->app->config('start'))->name('seq_items');
  $admin->post('/sequence/:n')->xhr->to('crud#update', m=>'seq_items', v=>'seq_items', start=>$self->app->config('start'))->name('seq_items');

  my $reports = $admin->under('/reports');
  $reports->post('/postcards')->xhr->to('crud#read', m=>'postcards', v=>'jqgrid');
  $reports->get('/postcards.xls')->to('crud#read', m=>'postcards', v=>'jqgrid', format=>'xls');
  $reports->post('/flyer')->xhr->to('crud#read', m=>'flyer', v=>'jqgrid');
  $reports->get('/flyer.xls')->to('crud#read', m=>'flyer', v=>'jqgrid', format=>'xls');
  $reports->post('/bankreport/:year', year=>qr/\d{4}/)->xhr->to('crud#read', m=>'bankreport', v=>'jqgrid');
  $reports->get('/bankreport.xls/:year', year=>qr/\d{4}/)->to('crud#read', m=>'bankreport', v=>'jqgrid', format=>'xls');

  my $sol_aids = $admin->under('/solicitation_aids');
  $sol_aids->get('/checklist')->xhr->to('crud#read', m=>'checklist', v=>'jqgrid');
  $sol_aids->get('/packets')->xhr->to('crud#read', m=>'packets', v=>'jqgrid');
  $sol_aids->get('/packet/:id', id=>qr/\d+/)->xhr->to('crud#read', m=>'packet', v=>'jqgrid');

  # Although this is a plugin, it's an autorouter, so it needs to be last
  # Routes are handled by first match
  $self->plugin('AutoRoute', {route => $self->routes});
}

sub setup_hooks {
    my ($self) = @_;
    $self->hook(before_dispatch => sub {
            my $c = shift;
            # As "defaults" values are not deep-copied, setting a hashref there
            # would just copy that hashref and stash modifications would actually
            # modify the defaults.
            $c->stash(info  => []);
            $c->stash(error => []);

            # Debug request logging
            my $year   = $self->config->{year};
            my $req    = $c->req;
            my $method = $req->method;
            my $path   = $req->url->path->to_abs_string;
            my $params = $req->params->to_string;
            print STDERR "REQ($year)  : $method $path [$params]\n" unless $path =~ /\.js$|\.css$/;
        });
}

sub setup_model {
    my $self = shift;
    my $config = $self->config('database');
    my $model = WRRA::Model->new(
        app => $self, # Give the Mojo app instance to the Model so that it can log or grab configuration info.
        schema => WRRA::Schema->connect({
            dsn         => "DBI:$config->{type}:database=$config->{name};host=$config->{host}",
            user        => $config->{user},
            password    => $config->{pass},
            #tabledefs   => $self->config('database_tables'),
            #newquota    => $self->config('new_quota_table'),
        }),
    );
    $model->schema->config($self->config);  # Pass the app's config to the schema
    $self->helper(model => sub { $model->model($_[1]) });
}

1;
