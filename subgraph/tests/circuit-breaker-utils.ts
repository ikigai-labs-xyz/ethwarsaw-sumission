import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  CircuitBreakerStatusUpdate,
  ParameterChanged
} from "../generated/CircuitBreaker/CircuitBreaker"

export function createCircuitBreakerStatusUpdateEvent(
  user: Address,
  newStatus: boolean
): CircuitBreakerStatusUpdate {
  let circuitBreakerStatusUpdateEvent = changetype<CircuitBreakerStatusUpdate>(
    newMockEvent()
  )

  circuitBreakerStatusUpdateEvent.parameters = new Array()

  circuitBreakerStatusUpdateEvent.parameters.push(
    new ethereum.EventParam("user", ethereum.Value.fromAddress(user))
  )
  circuitBreakerStatusUpdateEvent.parameters.push(
    new ethereum.EventParam("newStatus", ethereum.Value.fromBoolean(newStatus))
  )

  return circuitBreakerStatusUpdateEvent
}

export function createParameterChangedEvent(
  user: Address,
  newParameter: BigInt
): ParameterChanged {
  let parameterChangedEvent = changetype<ParameterChanged>(newMockEvent())

  parameterChangedEvent.parameters = new Array()

  parameterChangedEvent.parameters.push(
    new ethereum.EventParam("user", ethereum.Value.fromAddress(user))
  )
  parameterChangedEvent.parameters.push(
    new ethereum.EventParam(
      "newParameter",
      ethereum.Value.fromUnsignedBigInt(newParameter)
    )
  )

  return parameterChangedEvent
}
