/// Retorno de operações que podem falhar, usado na fronteira entre a camada de
/// dados e as ViewModels.
///
/// Repositórios devolvem `Result` em vez de lançar exceções: quem chama é
/// obrigado pelo compilador a tratar os dois casos (`switch` exaustivo sobre
/// uma sealed class), e a mensagem de erro já chega pronta para a tela — sem
/// a UI ter que adivinhar o que deu errado a partir de uma `Exception` crua.
sealed class Result<T> {
  const Result();
}

/// Operação concluída, com o valor produzido.
final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);
}

/// Operação falhou. [message] já está em português e pronta para exibição;
/// [cause] guarda o erro original para log/depuração.
final class Failure<T> extends Result<T> {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});
}
