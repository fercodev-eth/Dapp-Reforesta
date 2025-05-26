// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Arborizacion.sol";
import "./Reciclaje.sol";
import "./RecompensasNFT.sol";

contract DAppReforesta {
    Arborizacion public arborizacion;
    Reciclaje public reciclaje;
    RecompensasNFT public recompensasNFT;

    constructor() {
        arborizacion = new Arborizacion();
        reciclaje = new Reciclaje();
        recompensasNFT = new RecompensasNFT();
    }

    function plantarArbol(
        string memory especie,
        string memory clasificacion,
        uint altura,
        uint tallo,
        string memory distrito,
        string memory comunidad,
        string memory coordenadasGPS
    ) public {
        arborizacion.plantarArbol(especie, clasificacion, altura, tallo, distrito, comunidad, coordenadasGPS);
    }

    function registrarActividadReciclaje(
        string memory tipoMaterial,
        uint cantidad,
        string memory ubicacion
    ) public {
        reciclaje.registrarActividadReciclaje(tipoMaterial, cantidad, ubicacion);
    }

    function otorgarRecompensa(address beneficiario, string memory tokenURI) public {
        recompensasNFT.otorgarRecompensa(beneficiario, tokenURI);
    }
}