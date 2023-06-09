// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./owndefipair.sol";
import "./Iowndefipair.sol";
import "./Ipairfactory.sol";

contract pairfactory is Ipairfactory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair) {
        require(tokenA != tokenB, "pairfactory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "pairfactory: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "pairfactory: PAIR_EXISTS"
        );
        bytes memory bytecode = type(owndefipair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Iowndefipair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }
}
