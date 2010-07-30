package UFL::WebAdmin::SiteDeploy::Web;

use strict;
use warnings;
use parent qw/Catalyst/;

our $VERSION = '0.08';

__PACKAGE__->setup(qw/
    ConfigLoader
    Authentication
    AutoRestart
    ErrorCatcher
    StackTrace
    Static::Simple
    Unicode::Encoding
/);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Web - Web site deployment via a Web interface

=head1 SYNOPSIS

    script/ufl_webadmin_sitedeploy_web_server.pl

=head1 DESCRIPTION

This application interfaces with L<UFL::WebAdmin::SiteDeploy> and a
Subversion repository to simplify releasing changes to a Web site.

=head1 METHODS

=head2 finalize_error

Output a more friendly error page. This is based loosely on
L<Catalyst::Plugin::CustomErrorMessage>.

=cut

sub finalize_error {
    my $c = shift;

    # Allow ErrorCatcher to run
    $c->next::method(@_);

    # Allow StackTrace to take over in debug mode
    return if $c->debug;

    # Forward to the more friendly error page
    eval {
        $c->res->body($c->view('HTML')->render($c, 'error.tt'));
    };
    if ($@) {
        # Handle view-level errors by logging them
        $c->log->error($@);
    }
}

=head1 SEE ALSO

=over 4

=item * L<UFL::WebAdmin::SiteDeploy::Web::Controller::Root>

=item * L<UFL::WebAdmin::SiteDeploy>

=item * L<Catalyst>

=back

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
