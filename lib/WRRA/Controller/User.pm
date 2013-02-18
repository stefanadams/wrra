package WRRA::Controller::User;
use Mojo::Base 'WRRA::Controller::Base';

# The controller receives a request from a user, passes incoming data to the
# model and retrieves data from it, which then gets turned into an actual
# response by the view. But note that this pattern is just a guideline that
# most of the time results in cleaner more maintainable code, not a rule that
# should be followed at all costs.

# The controller decides how to handler data 
# The model retrieves data (DB Schema)
#   Receives data from controller and uses this to decide what data
# The view is responsible for deciding how it looks (rendering)

# The view asks for the data from the model
# The controller decides which model to use
# The model retries the appropriate data based on the request from the cntrlr

#              +----------------+     +-------+
#  Request  -> |                | <-> | Model |
#              |                |     +-------+
#              |   Controller   |
#              |                |     +-------+
#  Response <- |                | <-> | View  |
#              +----------------+     +-------+

# use Jqgrid;

sub index { shift->render_text('User Index') }

1;
