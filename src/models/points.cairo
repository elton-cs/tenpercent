use starknet::{ContractAddress};
use tenpercent::store::{Store, StoreTrait};
use dojo::world::WorldStorage;
use core::num::traits::Zero;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
struct Points {
    #[key]
    owner: ContractAddress,
    balance: u256,
}

const MAX_SUPPLY: u256 = 1_000_000_000_000_000_000_000;
const MIN_POINTS: u256 = 0;

#[generate_trait]
impl PointsImpl of PointsTrait {
    fn start_supply() -> Points {
        Points { owner: Zero::<ContractAddress>::zero(), balance: MAX_SUPPLY }
    }

    fn new(owner: ContractAddress) -> Points {
        Points { owner, balance: 0 }
    }

    fn add(ref self: Points, amount: u256) {
        assert!(amount > MIN_POINTS, "Amount must be greater than 0");
        assert!(self.balance + amount <= MAX_SUPPLY, "Max supply reached");
        self.balance += amount;
    }

    fn subtract(ref self: Points, amount: u256) {
        assert!(amount > MIN_POINTS, "Amount must be greater than 0");
        assert!(self.balance >= amount, "Insufficient balance");
        self.balance -= amount;
    }
}
