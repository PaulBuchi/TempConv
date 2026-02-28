import grpc from 'k6/net/grpc';
import { check, sleep } from 'k6';

const client = new grpc.Client();
const url = __ENV.GRPC_TARGET;

export const options = {
  vus: 50,
  duration: '30s',
};

export default () => {
  client.connect(url, { plaintext: true });
  const payload = { value: Math.random() * 100 };
  const response = client.invoke('api.tempconv.TempConvService/CelsiusToFahrenheit', payload);
  check(response, {
    'status is OK': r => r && r.status === grpc.StatusOK,
  });
  client.close();
  sleep(1);
};