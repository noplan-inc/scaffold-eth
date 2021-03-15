import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721BurnableMintable is ERC721 {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
    }

    function mint(address _to)
    public
    returns (uint256)
    {
        uint256 mintTokenId = totalSupply() + 1;

        _mint(_to, mintTokenId);
        return mintTokenId;
    }


    function burn(uint256 _tokenId)
    public
    returns (bool)
    {
        _burn(_tokenId);
        return true;
    }
}
