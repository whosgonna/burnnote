use utf8;
package Burnnote::Schema::Result::Note;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Burnnote::Schema::Result::Note

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<notes>

=cut

__PACKAGE__->table("notes");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 time

  data_type: 'int'
  is_nullable: 0

=head2 expires

  data_type: 'int'
  is_nullable: 0

=head2 message

  data_type: 'text'
  is_nullable: 1

=head2 internal

  data_type: (empty string)
  default_value: 1
  is_nullable: 1

=head2 read_count

  data_type: 'int'
  default_value: 0
  is_nullable: 1

=head2 read_limit

  data_type: 'int'
  default_value: null
  is_nullable: 1

=head2 password

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "time",
  { data_type => "int", is_nullable => 0 },
  "expires",
  { data_type => "int", is_nullable => 0 },
  "message",
  { data_type => "text", is_nullable => 1 },
  "internal",
  { data_type => "", default_value => 1, is_nullable => 1 },
  "read_count",
  { data_type => "int", default_value => 0, is_nullable => 1 },
  "read_limit",
  { data_type => "int", default_value => \"null", is_nullable => 1 },
  "password",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-09-03 15:57:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Bizd26dNoj2Ig9EoTbTyqw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
