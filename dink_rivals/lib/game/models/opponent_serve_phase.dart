/// State of the opponent's serve flow.
///
/// - [none]: not opponent's serve, or opponent has already served.
/// - [awaitingReady]: opponent is at the serve spot with the ball glued to
///   their racket; waiting for the player to tap "Ready" before counting down.
/// - [countingDown]: countdown is ticking; opponent serves automatically when
///   it reaches zero.
enum OpponentServePhase { none, awaitingReady, countingDown }
