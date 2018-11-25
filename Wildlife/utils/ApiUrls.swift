//
//  ApiUrls.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 23.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//
import Foundation

var port: String = ""

let eurekaClientUrl: String = "https://foobar.com"

let loginUrl: String = "/api/login"

func getAnimalUrl(username: String) -> String {
    return "/api/animals/" + username
}

func getCollarUrl(username: String) -> String {
    return "/api/collar/" + username
}

func getAnimalPositions(animalId: String) -> String {
    return "/api/animal_positions/" + animalId
}

func getAnimalCollarPositions(collarId: String) -> String {
    return "/api/animal_positions/collar/" + collarId
}

func getAnimalLastPosition(animalId: String) -> String {
    return "/api/animal_last_position/" + animalId
}

func getAnimalCollarLastPosition(collarId: String) -> String {
    return "/api/animal_last_position/collar/" + collarId
}

func getUserType(username: String) -> String {
    return "/api/usertype/" + username
}

func getUserGroupUser(adminName: String) -> String {
    return "/api/usergroup/user/" + adminName
}

func getCollarsSpecificTime(id: String, time: String) -> String {
    return "/api/animal_positions_time/collar/" + id + "/" + time
}

func getAnimalsSpecificTime(id: String, time: String) -> String {
    return "/api/animal_positions_time/" + id + "/" + time
}

func getCollarSize(username: String) -> String {
    return "/api/count_collar/" + username
}

func getAnimalSize(username: String) -> String {
    return "/api/count_animals/" + username
}

func getUserSize(username: String) -> String {
    return "/api/count_usergroup/" + username
}

func getAnimalPositionsBetweenByCollar(id: String, date1: String, date2: String) -> String {
    return "/api/animal_positions_time/between/collar/" + date1 + "%2000:00:00/" + date2 + "%2023:59:59/" + id
}

func getAnimalPositionsBetweenByCollarWithoutTime(id: String, date1: String, date2: String) -> String {
    return "/api/animal_positions_time/between/collar/" + date1 + "/" + date2 + "/" + id
}

func getAnimalPositionAfterByCollar(id: String, lastPos: String) -> String {
    return "/api/animal_positions_time/after/collar/" + lastPos + "/" + id
}

func getAnimalPositionsBetweenByAnimal(id: String, date1: String, date2: String) -> String {
    return "/api/animal_positions_time/between/animal/"  + date1 + "%2000:00:00/" + date2 + "%2023:59:59/" + id
}

func getAnimalPositionsBetweenByAnimalWithoutTime(id: String, date1: String, date2: String) -> String {
    return "/api/animal_positions_time/between/animal/"  + date1 + "/" + date2 + "/" + id
}

func getAnimalPositionAfterByAnimal(id: String, lastPos: String) -> String {
    return "/api/animal_positions_time/after/animal/" + lastPos + "/" + id
}
