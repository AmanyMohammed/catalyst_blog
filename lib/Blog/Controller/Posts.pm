package Blog::Controller::Posts;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Blog::Controller::Posts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Posts in Posts.');
}



sub base :Chained('/') :PathPart('posts') :CaptureArgs(0) {
    my ($self, $c) = @_;
 
    # Store the ResultSet in stash so it's available for other methods
    $c->stash(resultset => $c->model('DB::Post'));
 
    # Print a message to the debug log
    $c->log->debug('*** INSIDE BASE METHOD ***');
}

sub userObject :Chained('base') :PathPart('id') :CaptureArgs(1) {

    my ($self, $c, $id) = @_;

    $c->stash(resultset => $c->model('DB::User'));
    $c->stash(object => $c->stash->{resultset}->find($id));
 
    die "User $id not found!" if !$c->stash->{object};
 
    $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
}

sub list :Local {
	my ($self, $c) = @_;
	$c->stash(posts => [$c->model('DB::Post')->all]);
	$c->stash(template => 'posts/list.tt');
}


sub post_create :Chained('userObject') :PathPart('post_create') :Args(0) {
    my ($self, $c) = @_;
 
    # Set the TT template to use
    $c->stash(user=>$c->stash->{object},template => 'posts/post_create.tt');
    
}

sub post_create_do :Chained('base') :PathPart('post_create_do') :Args(0) {
    my ($self, $c) = @_;
 
    # Retrieve the values from the form
    my $postname     = $c->request->params->{postname}     || 'N/A';
    my $body    = $c->request->params->{body}    || 'N/A';
    my $createdBy = int $c->request->params->{createdBy} || 'N/A';
 
    # Create the post
    my $post = $c->model('DB::Post')->create({
            postname   => $postname,
            body  => $body,
	    createdby  => $createdBy,
        });

    $c->response->redirect($c->uri_for($self->action_for('list')));
    #$c->response->redirect($c->uri_for(c->controller('Users')->action_for('list')));
}
sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of book to delete
    my ($self, $c, $id) = @_;
    $c->stash(resultset => $c->model('DB::Post'));
    $c->stash(object => $c->stash->{resultset}->find($id));
 
    die "Post $id not found!" if !$c->stash->{object};
 
    $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
}

sub delete :Chained('object') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{object}->delete;

    $c->stash->{status_msg} = "Post deleted.";
 
    $c->response->redirect($c->uri_for($self->action_for('list')));
}
sub form_update :Chained('object') :PathPart('form_update') :Args(0) {
    my ($self, $c) = @_;
 
    # Set the TT template to use
    $c->stash(post=>$c->stash->{object},template => 'posts/form_update.tt');
}
sub update :Chained('object') :PathPart('update') :Args(0) {
    my ($self, $c) = @_;
    my $postname     = $c->request->params->{postname}     || 'N/A';
    my $body    = $c->request->params->{body}    || 'N/A';
   
    $c->stash->{object}->update({
	postname   => $postname,
        body  => $body,
	
    });
    $c->response->redirect($c->uri_for($self->action_for('list')));
} 
sub show :Chained('object') :PathPart('show') :Args(0) {
    my ($self, $c) = @_;
 
    # Set the TT template to use
    $c->stash(comments => [$c->model('DB::Comment')->all]);
    #$c->stash(template => 'posts/list.tt');
    $c->stash(post=>$c->stash->{object},template => 'posts/show.tt');
}
sub comment :Chained('object') :PathPart('comment') :Args(0) {
   my ($self, $c) = @_;
    my $body     = $c->request->params->{body}     || 'N/A';
    my $createdby     = $c->request->params->{createdby}     || 'N/A';
    my $comment = $c->model('DB::Comment')->create({
            body   => $body,
            postid  => $c->stash->{object}->id,
	    createdby   => $createdby,
        });
    
}

sub objectcomment :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of comment to delete
    my ($self, $c, $id) = @_;
    $c->stash(resultset => $c->model('DB::Comment'));
    $c->stash(object => $c->stash->{resultset}->find($id));
 
    die "Post $id not found!" if !$c->stash->{object};
 
    $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
}

sub deletecomment :Chained('objectcomment') :PathPart('deletecomment') :Args(0) {
    my ($self, $c) = @_;
 
    $c->stash->{object}->delete;
 
    $c->stash->{status_msg} = "Comment deleted.";
 
    $c->response->redirect($c->uri_for($self->action_for('list')));
}



=encoding utf8

=head1 AUTHOR

Amany Mohammed,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
