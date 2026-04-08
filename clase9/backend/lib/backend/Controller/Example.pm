package backend::Controller::Example;
use Mojo::Base 'Mojolicious::Controller', -signatures;

# This action will render a template
sub welcome ($self) {

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'HOla sean bienvenidos al curso 2026 EDD :) ');
}

1;
