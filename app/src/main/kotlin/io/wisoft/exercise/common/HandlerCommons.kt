package io.wisoft.exercise.common

import arrow.core.Either
import arrow.core.Either.Left
import arrow.core.Either.Right
import io.wisoft.exercise.common.Message.REQUEST_UUID_INVALID_FORMAT
import java.util.UUID
import org.springframework.web.reactive.function.server.ServerRequest

fun ServerRequest.parseUUIDOrLeft(): Either<Message, UUID> =
    try {
        Right(UUID.fromString(this.pathVariable("id")))
    } catch (e: IllegalArgumentException) {
        Left(REQUEST_UUID_INVALID_FORMAT)
    }
