// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract Defantasy {
    uint256 public constant ENERGY_PRICE = 1000000000000000;
    uint256 public constant MAP_W = 100;
    uint256 public constant MAP_H = 100;
    uint256 public constant TOTAL = MAP_W * MAP_H;

    address[] public participants;
    mapping(address => bool) public participated;
    mapping(address => uint256) private energies;

    function participate() internal {
        if (participated[msg.sender] != true) {
            participated[msg.sender] = true;
            participants.push(msg.sender);
        }
    }

    function buyEnergy() external payable {
        uint256 quantity = msg.value / ENERGY_PRICE;
        energies[msg.sender] += quantity;
        assert(energies[msg.sender] >= quantity);
        participate();
    }

    struct Support {
        address to;
        uint256 quantity;
    }
    mapping(address => Support[]) private supported;

    function support(address to, uint256 quantity) external {
        assert(quantity <= energies[msg.sender]);
        energies[msg.sender] -= quantity;

        energies[to] += quantity;
        assert(energies[to] >= quantity);

        supported[msg.sender].push(Support({to: to, quantity: quantity}));
    }

    uint256 public season = 1;

    enum ArmyKind {Fire, Water, Wind, Earth, Light, Dark}
    struct Army {
        ArmyKind kind;
        uint256 count;
        address owner;
    }
    Army[][] public map;
    mapping(address => uint16) private occupied;

    function enter(
        uint8 x,
        uint8 y,
        ArmyKind kind,
        uint256 count
    ) external {}

    function attack(
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY
    ) external {
        // win.
        if (occupied[msg.sender] == TOTAL) {
            reward(msg.sender);
            clear();
        }
    }

    function reward(address winner) internal {
        // calculate reward rate.
    }

    function clear() internal {
        for (uint256 i = 0; i < participants.length; i += 1) {
            delete participated[participants[i]];
            delete energies[participants[i]];
            delete supported[participants[i]];
            delete occupied[participants[i]];
        }
        delete participants;
        delete map;
    }
}
