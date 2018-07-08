package burnnote;
use Modern::Perl;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Data::Printer;
use Data::GUID 'guid_string';
use Net::IP::Match::Regexp qw( create_iprange_regexp match_ip );



our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'burnnote' };
};

post '/' => sub {
    my $url = request->base;

    my $add = add_message({
        message  => body_parameters->get('message'),
        internal => ( body_parameters->get('internal') ? 1 : 0 ),
        id       => guid_string(),
        time     => time()
    });

    
    $url .= $add->id;

    template 'index' => { 'title' => 'burnnote', url => $url};
};

get '/:id' => sub {
    my $id  = route_parameters->get('id');
    my $row = get_row($id);
}


sub add_message {
    my $params = shift;
    my $rs = resultset('Note');
    my $res = $rs->create( $params );
    return $res;

};


sub get_row {
    my $id = shift;
    my $rs = resultset('Note')->find($id);
}


true;
