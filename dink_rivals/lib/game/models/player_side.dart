enum PlayerSide { player, opponent }

extension PlayerSideX on PlayerSide {
  PlayerSide get opponent {
    return this == PlayerSide.player ? PlayerSide.opponent : PlayerSide.player;
  }
}
