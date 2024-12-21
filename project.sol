// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlogIncentives {
    struct Article {
        address author;
        string title;
        string content;
        uint256 incentivesEarned;
    }

    address public owner;
    uint256 public totalArticles;
    mapping(uint256 => Article) public articles;

    event ArticlePublished(uint256 articleId, address indexed author, string title);
    event IncentivePaid(address indexed author, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function publishArticle(string memory _title, string memory _content) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_content).length > 0, "Content cannot be empty");

        articles[totalArticles] = Article({
            author: msg.sender,
            title: _title,
            content: _content,
            incentivesEarned: 0
        });

        emit ArticlePublished(totalArticles, msg.sender, _title);
        totalArticles++;
    }

    function payIncentive(uint256 _articleId, uint256 _amount) public payable onlyOwner {
        require(_articleId < totalArticles, "Invalid article ID");
        require(msg.value == _amount, "Sent value does not match the specified amount");

        Article storage article = articles[_articleId];
        article.incentivesEarned += _amount;

        payable(article.author).transfer(_amount);

        emit IncentivePaid(article.author, _amount);
    }

    function getArticle(uint256 _articleId) public view returns (
        address author,
        string memory title,
        string memory content,
        uint256 incentivesEarned
    ) {
        require(_articleId < totalArticles, "Invalid article ID");
        Article storage article = articles[_articleId];
        return (article.author, article.title, article.content, article.incentivesEarned);
    }
}
