import { Address, Bytes } from "@graphprotocol/graph-ts"

export function getId(address: Address, txHash: Bytes): string {
	return address.toHex() + "-" + txHash.toString()
}
