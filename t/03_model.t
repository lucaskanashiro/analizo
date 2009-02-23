package ModelTests;
use base qw(Test::Class);
use Test::More;
use strict;

use Egypt::Model;

sub constructor : Tests {
  isa_ok(new Egypt::Model, 'Egypt::Model');
}

sub empty_object : Tests {
  my $model = new Egypt::Model;
  isa_ok($model->modules, 'HASH', 'must have modules');
  isa_ok($model->members, 'HASH', 'must have members');
}

sub declaring_function : Tests {
  my $model = new Egypt::Model;
  $model->declare_function('mymodule', 'myfunction');
  ok((grep { $_ eq 'myfunction' } keys(%{$model->members})), "declared function must be stored");
  is('mymodule', $model->members->{'myfunction'}, 'must map function to module');
  ok((grep { $_ eq 'mymodule'} keys(%{$model->modules})), 'declaring a function must declare its module');
  ok((grep { $_ eq 'myfunction' } @{$model->modules->{'mymodule'}}), 'must store members in a module');
}

sub declaring_function_with_demangled_name : Tests {
  my $model = new Egypt::Model;
  $model->declare_function('mymodule', 'myfunction', 'demangled_name');
  ok((grep { $_ eq 'demangled_name'} $model->demangle('myfunction')), 'must store mapping from mangled name to demangled name')
}

sub use_mangled_name_by_default_when_demanglig : Tests {
  my $model = new Egypt::Model;
  $model->declare_function("mod1", 'f1');
  is($model->demangle('f1'), 'f1', 'must demangle to the function name itself by default');
}

sub declaring_variables : Tests {
  my $model = new Egypt::Model;
  $model->declare_variable('mymodule', 'myvariable');
  ok((grep { $_ eq 'myvariable' } keys(%{$model->members})), "declared variable must be stored");
  is('mymodule', $model->members->{'myvariable'}, 'must map variable to module');
  ok((grep { $_ eq 'mymodule'} keys(%{$model->modules})), 'declaring a variable must declare its module');
  ok((grep { $_ eq 'myvariable' } @{$model->modules->{'mymodule'}}), 'must store variable in a module');
}

sub adding_calls : Tests {
  my $model = new Egypt::Model;
  $model->add_call('function1', 'function2');
  is($model->calls->{'function1'}->{'function2'}, 'direct', 'must register function call');
}

sub indirect_calls : Tests {
  my $model = new Egypt::Model;
  $model->add_call('f1', 'f2', 'indirect');
  is($model->calls->{'f1'}->{'f2'}, 'indirect', 'must register indirect call');
}

sub addding_variable_uses : Tests {
  my $model = new Egypt::Model;
  $model->add_variable_use('function1', 'variable9');
  is($model->calls->{'function1'}->{'variable9'}, 'variable', 'must register variable use');
}

sub querying_type_of_member_and_members_by_type : Tests {
  my $model = new Egypt::Model;
  $model->declare_function('mod1', 'f1');
  $model->declare_variable('mod1', 'v1');
  is($model->type('f1'), 'function');
  is($model->type('v1'), 'variable');

  $model->declare_function('mod1', 'f2');
  $model->declare_variable('mod1', 'v2');

  ok((grep { $_ eq 'f1' } $model->functions('mod1')), 'must list f1 in functions');
  ok((grep { $_ eq 'f2' } $model->functions('mod1')), 'must list f2 in functions');
  ok((grep { $_ eq 'v1' } $model->variables('mod1')), 'must list v1 in variables');
  ok((grep { $_ eq 'v2' } $model->variables('mod1')), 'must list v2 in variables');

}

ModelTests->runtests;