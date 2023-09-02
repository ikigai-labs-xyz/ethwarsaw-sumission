import { BigInt } from "@graphprotocol/graph-ts"
import {
	CircuitBreaker,
	CircuitBreakerStatusUpdate,
	ParameterChanged,
} from "../generated/CircuitBreaker/CircuitBreaker"
import { ParameterValue, Protocol } from "../generated/schema"
import { getId } from "./utils"

export function handleCircuitBreakerStatusUpdate(event: CircuitBreakerStatusUpdate): void {
	let protocol = Protocol.load(event.params.user.toHex())
	if (!protocol) {
		protocol = new Protocol(event.params.user.toHex())
	}
	protocol.status = event.params.newStatus

	protocol.save()
}

export function handleParameterChanged(event: ParameterChanged): void {
	let protocol = Protocol.load(event.params.user.toHex())
	if (!protocol) {
		protocol = new Protocol(event.params.user.toHex())
	}

	let parameterValueId = getId(event.params.user, event.transaction.hash)
	let parameterValue = new ParameterValue(parameterValueId)
	parameterValue.value = event.params.newParameter
	parameterValue.blockNumber = event.transaction.index
	parameterValue.save()

	protocol.save()
}
