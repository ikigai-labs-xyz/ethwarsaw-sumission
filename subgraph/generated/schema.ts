// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  TypedMap,
  Entity,
  Value,
  ValueKind,
  store,
  Bytes,
  BigInt,
  BigDecimal
} from "@graphprotocol/graph-ts";

export class Protocol extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Protocol entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type Protocol must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`
      );
      store.set("Protocol", id.toString(), this);
    }
  }

  static loadInBlock(id: string): Protocol | null {
    return changetype<Protocol | null>(store.get_in_block("Protocol", id));
  }

  static load(id: string): Protocol | null {
    return changetype<Protocol | null>(store.get("Protocol", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get status(): boolean {
    let value = this.get("status");
    if (!value || value.kind == ValueKind.NULL) {
      return false;
    } else {
      return value.toBoolean();
    }
  }

  set status(value: boolean) {
    this.set("status", Value.fromBoolean(value));
  }

  get value(): string {
    let value = this.get("value");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set value(value: string) {
    this.set("value", Value.fromString(value));
  }

  get historicalValues(): ParameterValueLoader {
    return new ParameterValueLoader(
      "Protocol",
      this.get("id")!.toString(),
      "historicalValues"
    );
  }
}

export class ParameterValue extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save ParameterValue entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type ParameterValue must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`
      );
      store.set("ParameterValue", id.toString(), this);
    }
  }

  static loadInBlock(id: string): ParameterValue | null {
    return changetype<ParameterValue | null>(
      store.get_in_block("ParameterValue", id)
    );
  }

  static load(id: string): ParameterValue | null {
    return changetype<ParameterValue | null>(store.get("ParameterValue", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get protocol(): ProtocolLoader {
    return new ProtocolLoader(
      "ParameterValue",
      this.get("id")!.toString(),
      "protocol"
    );
  }

  get value(): BigInt {
    let value = this.get("value");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set value(value: BigInt) {
    this.set("value", Value.fromBigInt(value));
  }

  get blockNumber(): BigInt {
    let value = this.get("blockNumber");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set blockNumber(value: BigInt) {
    this.set("blockNumber", Value.fromBigInt(value));
  }
}

export class ParameterValueLoader extends Entity {
  _entity: string;
  _field: string;
  _id: string;

  constructor(entity: string, id: string, field: string) {
    super();
    this._entity = entity;
    this._id = id;
    this._field = field;
  }

  load(): ParameterValue[] {
    let value = store.loadRelated(this._entity, this._id, this._field);
    return changetype<ParameterValue[]>(value);
  }
}

export class ProtocolLoader extends Entity {
  _entity: string;
  _field: string;
  _id: string;

  constructor(entity: string, id: string, field: string) {
    super();
    this._entity = entity;
    this._id = id;
    this._field = field;
  }

  load(): Protocol[] {
    let value = store.loadRelated(this._entity, this._id, this._field);
    return changetype<Protocol[]>(value);
  }
}
