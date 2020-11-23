// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract Defantasy {
    uint256 private constant ENERGY_PRICE = 1000000000000000;

    struct Army {
        uint256 kind;
        uint256 number;
        address owner;
        uint256 time;
    }

    uint256 public season;
    Army[][] public map;
    mapping(address => uint256) private energies;

    function buyEnergy() external payable {
        uint256 quantity = msg.value / ENERGY_PRICE;
        energies[msg.sender] += quantity;
        assert(energies[msg.sender] >= quantity);
    }

    function join() external {}

    function support() external {}
}
