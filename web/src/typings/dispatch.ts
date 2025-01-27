import { Officer } from './officer';

export type UnitType = 'car' | 'motor' | 'heli' | 'boat';

export interface Call {
  id: number;
  offense: string;
  code: string;
  completed: false | number;
  linked: boolean;
  coords: [number, number];
  blip: number;
  info: {
    time: number;
    location: string;
    plate?: string;
    vehicle?: string;
  };
  units: Unit[];
}

export interface Unit {
  id: number;
  name: string;
  members: Officer[];
  type: UnitType;
}

export type UnitsObject = { [key: string]: Omit<Unit, 'id'> };
