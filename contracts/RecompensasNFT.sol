// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RecompensasNFT is ERC721URIStorage, Ownable {
    uint256 public tokenCount;

    constructor() ERC721("RecompensasNFT", "RFST")Ownable(msg.sender) {}

    function otorgarRecompensa(address _usuario, string memory _metadatosURI) public onlyOwner {
        tokenCount++;
        _mint(_usuario, tokenCount);
        _setTokenURI(tokenCount, _metadatosURI);
    }
    function obtenerRecompensa() public view returns (uint256) {
            return tokenCount;
    }

    function calcularRecompensa(uint256 _arbolesPlantados, uint256 _materialReciclado)public pure returns (uint256)
    {
        // Lógica simplificada: 1 árbol plantado = 1 NFT, 10 unidades de material reciclado = 1 NFT
        return _arbolesPlantados + (_materialReciclado / 10);
    }
}