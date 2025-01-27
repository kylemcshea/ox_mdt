import { atom, useAtomValue, useSetAtom } from 'jotai';
import { Config } from '../typings';

const configAtom = atom<Config>({
  permissions: {
    announcements: {
      create: 3,
      delete: 4,
    },
  },
});

export const useConfig = () => useAtomValue(configAtom);
export const useSetConfig = () => useSetAtom(configAtom);
