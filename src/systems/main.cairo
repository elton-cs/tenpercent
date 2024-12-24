#[starknet::interface]
trait IMainTrait<TContractState> {
    fn flip(ref self: TContractState);
}


#[dojo::contract]
mod main {
    use super::IMainTrait;
    use dojo::world::WorldStorage;
    use tenpercent::store::{Store, StoreTrait};
    use tenpercent::models::coin::Coin;

    const ULTIMATE_COIN: felt252 = 'ultimate_coin';

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    fn dojo_init(self: @ContractState) {
        let mut store = StoreTrait::new(self.world_storage());
        let coin = Coin { id: ULTIMATE_COIN, flip: false };
        store.write_coin(@coin);
    }

    #[abi(embed_v0)]
    impl MainImpl of IMainTrait<ContractState> {
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
