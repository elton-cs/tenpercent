use dojo::world::WorldStorage;
use dojo::model::ModelStorage;
use starknet::ContractAddress;

use tenpercent::models::coin::Coin;
use tenpercent::models::points::Points;
use tenpercent::models::dice::Dice;

#[derive(Copy, Drop)]
struct Store {
    world: WorldStorage,
}

#[generate_trait]
impl StoreImpl of StoreTrait {
    #[inline]
    fn new(world: WorldStorage) -> Store {
        Store { world: world }
    }

    #[inline]
    fn read_coin(self: @Store, id: felt252) -> Coin {
        self.world.read_model(id)
    }

    #[inline]
    fn write_coin(ref self: Store, coin: @Coin) {
        self.world.write_model(coin)
    }

    #[inline]
    fn read_points(self: @Store, owner: ContractAddress) -> Points {
        self.world.read_model(owner)
    }

    #[inline]
    fn write_points(ref self: Store, points: @Points) {
        self.world.write_model(points)
    }

    #[inline]
    fn read_dice(self: @Store, face_count: u8) -> Dice {
        self.world.read_model(face_count)
    }

    #[inline]
    fn write_dice(ref self: Store, dice: @Dice) {
        self.world.write_model(dice)
    }
}
