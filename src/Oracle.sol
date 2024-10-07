// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRealityETHAdapter {
    function askQuestionWithMinBond(
        uint256 template_id,
        string memory question,
        address arbitrator,
        uint32 timeout,
        uint32 opening_ts,
        uint256 nonce,
        uint256 min_bond
    ) external payable returns (bytes32);

    function resultForOnceSettled(bytes32 question_id) external view returns (bytes32);

    function getContentHash(bytes32 question_id) external view returns (bytes32);

    function getTimeout(bytes32 question_id) external view returns (uint32);

    function submitAnswer(bytes32 question_id, bytes32 answer, uint256 max_previous) external payable;

    function getBestAnswer(bytes32 question_id) external view returns (bytes32);

}

contract Oracle is IRealityETHAdapter {
    mapping(bytes32 => bytes32) private questions;
    mapping(bytes32 => bytes32) private answers;
    mapping(bytes32 => uint32) private timeouts;
    mapping(bytes32 => bool) private settled;

    IRealityETHAdapter private realityETH;

    constructor(address _realityETHAddress) {
        require(_realityETHAddress != address(0), "Invalid Reality.eth address");
        realityETH = IRealityETHAdapter(_realityETHAddress);
    }

    function askQuestionWithMinBond(
        uint256 template_id,
        string memory question,
        address arbitrator,
        uint32 timeout,
        uint32 opening_ts,
        uint256 nonce,
        uint256 min_bond
    ) external payable override returns (bytes32) {
        bytes32 questionId = keccak256(abi.encodePacked(question, nonce));
        require(questions[questionId] == bytes32(0), "Question already exists");
        
        questions[questionId] = keccak256(abi.encodePacked(question));
        timeouts[questionId] = timeout;
        
        return questionId;
    }

    function resultForOnceSettled(bytes32 question_id) external view override returns (bytes32) {
        require(settled[question_id], "Question not settled");
        return answers[question_id];
    }

    function getContentHash(bytes32 question_id) external view override returns (bytes32) {
        return questions[question_id];
    }

    function getTimeout(bytes32 question_id) external view override returns (uint32) {
        return timeouts[question_id];
    }

    function submitAnswer(bytes32 question_id, bytes32 answer, uint256 max_previous) external payable override {
        require(questions[question_id] != bytes32(0), "Question does not exist");
        require(!settled[question_id], "Question already settled");
        
        answers[question_id] = answer;
        settled[question_id] = true;
    }

    function getBestAnswer(bytes32 question_id) external view override returns (bytes32) {
        return answers[question_id];
    }

}
