use core::poseidon::PoseidonTrait;
use core::hash::HashStateTrait;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
struct Dice {
    #[key]
    face_count: u8,
    seed: felt252,
    nonce: felt252,
    roll: u8,
}

#[generate_trait]
impl DiceImpl of DiceTrait {
    #[inline(always)]
    fn new(face_count: u8, seed: felt252) -> Dice {
        Dice { face_count, seed, nonce: 0, roll: 0 }
    }

    #[inline(always)]
    fn roll(ref self: Dice) {
        let mut state = PoseidonTrait::new();
        state = state.update(self.seed);
        state = state.update(self.nonce);
        self.nonce += 1;
        let random: u256 = state.finalize().into();
        self.roll = (random % self.face_count.into() + 1).try_into().unwrap();
    }
}
