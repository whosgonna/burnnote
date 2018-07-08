package burnnote;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Data::Printer;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'burnnote' };
};

post '/' => sub {
    my $body = body_parameters->as_hashref;
    p $body;
    validate_input();
    template 'index' => { 'title' => 'burnnote' };
};


sub validate_input {
};


true;
