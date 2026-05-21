package Test::Prompt::Ask;
use Mojo::Base 'MCP::Prompt', -signatures;

has arguments   => sub { return [{name => 'question', description => 'The question to ask', required => 1}] };
has description => 'Ask a question';
has code        => sub { return \&ask };
has name        => 'ask';

sub ask ($prompt, $input) {
  my $question = $input->{question} // 'What is your question?';
  return $prompt->context->controller->ask($question);
}

1;
