#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
struct Coin {
    #[key]
    id: felt252,
    flip: bool,
}
