requires "Dancer2" => "0.205002";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};

requires 'Modern::Perl';
requires 'Dancer2';
requires 'Dancer2::Plugin::DBIC';
requires 'Dancer2::Plugin::Ajax';
requires 'Data::Uniqid';
requires 'Net::IP::Match::Regexp';
requires 'Template::Plugin::Lingua::EN::Inflect';
~
