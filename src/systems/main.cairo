#[starknet::interface]
trait IMainTrait<TContractState> {
    fn start_game(ref self: TContractState);
    fn points_up(ref self: TContractState);
    fn points_down(ref self: TContractState);
    fn gamble(ref self: TContractState);
    fn flip(ref self: TContractState);
}


#[dojo::contract]
mod main {
    use super::IMainTrait;
    use core::num::traits::Zero;
    use starknet::{ContractAddress, get_caller_address};
    use dojo::world::WorldStorage;

    use tenpercent::store::{Store, StoreTrait};
    use tenpercent::models::coin::Coin;
    use tenpercent::models::points::{Points, PointsTrait};
    use tenpercent::models::dice::{Dice, DiceTrait};

    const ULTIMATE_COIN: felt252 = 'ultimate_coin';
    const DECIMAL_MULTIPLIER: u256 = 1_000_000;
    const DICE_SEED: felt252 = 'PREDICTABLY_RANDOM';
    const DICE_KEY: u8 = 2;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    fn dojo_init(self: @ContractState) {
        let mut store = StoreTrait::new(self.world_storage());

        let coin = Coin { id: ULTIMATE_COIN, flip: false };
        store.write_coin(@coin);

        let points = PointsTrait::start_supply();
        store.write_points(@points);

        let dice = DiceTrait::new(DICE_KEY, DICE_SEED);
        store.write_dice(@dice);
    }

    #[abi(embed_v0)]
    impl MainImpl of IMainTrait<ContractState> {
        fn start_game(ref self: ContractState) {
            let mut store = StoreTrait::new(self.world_storage());
            let points = 100 * DECIMAL_MULTIPLIER;

            let mut supply = store.read_points(Zero::<ContractAddress>::zero());
            supply.subtract(points);
            store.write_points(@supply);

            let caller = get_caller_address();
            let mut caller_points = PointsTrait::new(caller);
            caller_points.add(points);
            store.write_points(@caller_points);
        }

        fn gamble(ref self: ContractState) {
            let mut store = StoreTrait::new(self.world_storage());
            let mut dice = store.read_dice(DICE_KEY);
            dice.roll();
            store.write_dice(@dice);
        }

        fn points_up(ref self: ContractState) {
            let mut store = StoreTrait::new(self.world_storage());
            let points = 100 * DECIMAL_MULTIPLIER;

            let mut supply = store.read_points(Zero::<ContractAddress>::zero());
            supply.subtract(points);
            store.write_points(@supply);

            let mut caller_points = store.read_points(get_caller_address());
            caller_points.add(points);
            store.write_points(@caller_points);
        }

        fn points_down(ref self: ContractState) {
            let mut store = StoreTrait::new(self.world_storage());
            let points = 100 * DECIMAL_MULTIPLIER;

            let mut supply = store.read_points(Zero::<ContractAddress>::zero());
            supply.add(points);
            store.write_points(@supply);

            let mut caller_points = store.read_points(get_caller_address());
            caller_points.subtract(points);
            store.write_points(@caller_points);
        }

        fn flip(ref self: ContractState) {
            let mut store = StoreTrait::new(self.world_storage());
            let mut coin = store.read_coin(ULTIMATE_COIN);
            coin.flip = !coin.flip;
            store.write_coin(@coin);
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        #[inline]
        fn world_storage(self: @ContractState) -> WorldStorage {
            self.world(@"tenpercent")
        }
    }
}
