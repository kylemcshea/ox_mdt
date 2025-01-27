import { Call, Unit, UnitsObject } from '../typings';

export interface CallsResponse extends Omit<Call, 'id' | 'units'> {
  units: UnitsObject;
}

export const convertUnitsToArray = (units: UnitsObject): Unit[] => {
  if (!units) return [];
  return Object.entries(units).map((unit) => ({ id: +unit[0], ...unit[1] }));
};

export const convertCalls = (resp: { [key: string]: CallsResponse }): Call[] => {
  return Object.entries(resp).map((entry: [string, CallsResponse]) => {
    const call: Call = { id: +entry[0], ...entry[1], units: [] };
    call.units = convertUnitsToArray(entry[1].units);

    return call;
  });
};

interface CallResponse extends Omit<Call, 'units'> {
  units: UnitsObject;
}

export const convertCall = (resp: CallResponse): Call => {
  const units = convertUnitsToArray(resp.units);

  return { ...resp, units };
};
