package burnnote;
use Modern::Perl;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Data::Printer;
use Data::GUID 'guid_string';
use Net::IP::Match::Regexp qw( create_iprange_regexp match_ip );


our $VERSION = '0.1';

info "Starting Burn Note";

my $private_ip = create_iprange_regexp(
   qw( 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 )
);

get '/' => sub {
    info "this is a request";
    template 'index' => { 'title' => 'Burn Note' };
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

    template 'index' => { 'title' => 'Burn Note', url => $url};
};

get '/:id' => sub {
    my $id  = route_parameters->get('id');
    my $rec = get_rec($id);

    my $params = {
        title => 'Burn Note',
        id    => $id,
    };


    if (!$rec ) {
        $params->{no_message} = $id;
        info "mesage id $id not found";
        return template index => $params;
    }

    my $stale = time() - (24 * 60 * 60 );
    if ($rec->time < $stale ) {
        $params->{stale} = $id;
        del_rec( $id );
        return template index => $params;
    }

    my $rmt_ip = request_header 'x-real-ip'; #request->address;

    if ($rec->internal && !match_ip($rmt_ip, $private_ip)) {
        info "Remote IP was external, $rmt_ip, but private IP was required";
        $params->{external} = $rmt_ip;
        return template index => $params;
    }
            

    $params->{message} = $rec->message;
    del_rec( $id );
    template 'index' => $params;

};


sub add_message {
    my $params = shift;
    my $rs = resultset('Note');
    my $res = $rs->create( $params );
    return $res;

};


sub get_rec {
    my $id  = shift;
    my $rec = resultset('Note')->find($id);
    return $rec;
}

sub del_rec {
    my $id = shift;
    my $del = resultset('Note')->find($id)->delete;
    return $del;
}

true;
