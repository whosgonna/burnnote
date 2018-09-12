package burnnote;
use Modern::Perl;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Ajax;
#use Data::Printer;
use Data::Uniqid ( 'uniqid' );
use Net::IP::Match::Regexp qw( create_iprange_regexp match_ip );
use Template::Plugin::Lingua::EN::Inflect;


our $VERSION = '0.1';

info "Starting Burn Note. Environment: " . config->{environment};

my $private_ip = create_iprange_regexp(
   qw( 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 )
);

get '/' => sub {
    my $salt = uniqid();
    template 'index' => { 'title' => 'Burn Note', salt => $salt };
};

post '/' => sub {
    my $url  = request->base;
    my $salt = uniqid();
    

    my $params = body_parameters;

    my $add = add_message({
        message     => body_parameters->get('save_message'),,
        internal    => ( body_parameters->get('internal') ? 1 : 0 ),
        read_count  => ( body_parameters->get('read_count') // 0 ),
        read_limit  => ( body_parameters->get('read_limit') // 1 ),
        id          => uniqid(),
        time        => time(),
        expires     => time() + (  body_parameters->get('expires') * 3600 ),
        salt        => body_parameters->get('salt'),
        hashed_salt => body_parameters->get('hashed_salt'),
    });

    
    $url .= $add->id;

    template 'index' => { 'title' => 'Burn Note', url => $url, salt => $salt};
};

get '/:id' => sub {
    my $id  = route_parameters->get('id');
    my $rmt_ip = request_header 'x-real-ip'; # request->address;
    $rmt_ip //= request->address;
    info "Request fror message id $id from $rmt_ip";

    my $salt = uniqid();

    my $rec = get_rec($id);



    my $params = {
        title => 'Burn Note',
        id    => $id,
        salt  => $salt,
    };


    if (!$rec ) {
        $params->{no_message} = $id;
        info "mesage id $id not found";
        return template index => $params;
    }

    if ( time() > $rec->expires ) {
        $params->{stale} = $id;
        info "Message $id is expired";
        clear_rec( $id );
        return template index => $params;
    }

    if ( $rec->read_limit && ($rec->read_limit <= $rec->read_count) ) {
        my $read_limit = $rec->read_limit;
        info "Message $id has reached it's read_limit ($read_limit)";
        $params->{read_limit} = $read_limit;
        clear_rec( $id );
        return template index => $params;
    }


    if ($rec->internal && !match_ip($rmt_ip, $private_ip)) {
        info "Remote IP was external, $rmt_ip, but private IP was required";
        $params->{external} = $rmt_ip;
        return template index => $params;
    }
            
    ## If we get this far, we're displaying the message.
    if ( $rec->hashed_salt ) {
        $params->{salt_record} = $rec->salt;
        $params->{message} = q{};
        
        return template 'index' => $params;
    }

    $params->{message} = $rec->message;
    $params->{expires} = $rec->expires;
    my $inc = increment_read( $rec );
    if ( $rec->read_limit ) {
        $params->{remaining} = $inc->read_limit > $inc->read_count 
          ? $inc->read_limit - $inc->read_count
          : 0 ;
    }
    return template 'index' => $params;

};



ajax '/:id' => sub {
    #my $jstruct = encode_json( $struct );
    my $id   = route_parameters->get('id');
    my $hash = body_parameters->get('hash');

    my $rec = get_rec( $id );

    my $return;

    if ( lc($rec->hashed_salt) eq lc($hash) ) {
        $return = {
            result => 'success',
            message => $rec->message
        };
        my $inc = increment_read( $rec );
    }
    else {
        $return = { 
            result => 'failure'
        };
    }


    return encode_json( $return );
};



sub add_message {
    my $params = shift;
    my $rs = resultset('Note');
    my $res = $rs->create( $params );
    return $res;

};

sub check_rec {
    # Whereas the get_rec() method will retrieve the message body, the
    # check_rec() method will validate that is is OK to send the message
    # to the user.
    my $rec = shift;
    if ( !check_msg_count($rec) ) {
        $rec->message(undef);
    }
}

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

sub clear_rec {
    my $id    = shift;
    my $clear = resultset('Note')
      ->find($id)
      ->update({
          message => undef
      });
    return $clear;
}


sub increment_read {
    my $rec = shift;
    my $id  = $rec->id;
    my $cnt = $rec->read_count;
    my $inc = resultset('Note')
      ->find($id)
      ->update({
        read_count => ++$cnt
      });
    if ( $inc->read_limit && ($inc->read_count >= $inc->read_limit) ) {
        return( clear_rec($id) );
    }
    return $inc;
}

sub check_msg_count {
    my $rec = shift;
    if ( $rec->read_count < $rec->read_limit ) {
        return 1;
    }
    return undef;
}

true;
