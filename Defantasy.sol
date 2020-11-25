// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract Defantasy {
    uint256 public constant ENERGY_PRICE = 100000000000000;
    uint256 public constant SUMMON_ENERGY = 10;
    uint256 public constant MOVE_ENERGY = 1;
    uint256 public constant MAP_W = 100;
    uint256 public constant MAP_H = 100;
    uint256 public constant TOTAL = MAP_W * MAP_H;

    address payable public author;

    constructor() public {
        author = msg.sender;
    }

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

        // 3.75% fee.
        author.transfer((msg.value / 10000) * 375);
    }

    struct Support {
        address to;
        uint256 quantity;
    }
    mapping(address => Support[]) private supported;

    function support(address to, uint256 quantity) external {
        require(quantity <= energies[msg.sender]);
        energies[msg.sender] -= quantity;

        energies[to] += quantity;
        assert(energies[to] >= quantity);

        supported[msg.sender].push(Support({to: to, quantity: quantity}));
    }

    uint256 public season = 1;

    enum ArmyKind {Light, Fire, Water, Wind, Earth, Dark}
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
    ) external {
        require(x < MAP_W);
        require(y < MAP_H);
        require(kind >= ArmyKind.Light && kind <= ArmyKind.Dark);
        require(energies[msg.sender] >= count * SUMMON_ENERGY);
        require(map[y][x].owner == address(0));

        // must first time.
        for (uint8 mapY = 0; mapY < MAP_H; mapY += 1) {
            for (uint8 mapX = 0; mapX < MAP_W; mapX += 1) {
                if (map[mapY][mapX].owner == msg.sender) {
                    revert();
                }
            }
        }

        map[y][x] = Army({kind: kind, count: count, owner: msg.sender});
    }

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
