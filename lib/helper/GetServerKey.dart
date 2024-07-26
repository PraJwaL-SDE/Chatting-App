import 'package:googleapis_auth/auth_io.dart';

class Getserverkey{
   Future<String> getServerKeyToken() async{
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final clientCredentials = {
      "type": "service_account",
      "project_id": "chatting-app-2-8e7d4",
      "private_key_id": "b4a4d95b4e002b9fa8daf178279a8f3f5b6c3098",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDVGGxYRU6EnmWA\nOSCtsYISH4G3jelhiXvQAmnNY3Ha+G4bpy3nvgdi3YbS0Lt1IsemddRWaiToO6o9\ndvu4QER3Go1vn3CjSzzLc0UcIfn4kx+hta8rRpo/LF2//83P8g47YxV2TH2OBDWe\nmVdc6dVjn6HSBLMku+BUPVQ4a4NRFrwuwqfwDr3t8VIGvaTwkvf+3W5axdRu7clE\n8j9NQGyLpEJKqOIQZ/MxreRhPB2BEhVs7OT9M9GlJ6dTXEl9MlxqNed86OZ78HiY\nhgf1Q+28hz4HOgHYB4gNRH45zV8Xao+Mg5k1aTKtzRpv7fHIZpJh3UcgyDyuuGF5\n2sCenV+VAgMBAAECggEABd1bNf60+ioQfxE+GKmsURVe5joDSfTqXGovQUDTDwS2\npbovJZPxnhicr6FLrMidQrPheSizWqoxtZQDD39tTZ3Zy1BRsvIiJTNHRqPvaOub\npkFa0Hpr9QB36rh+kJIyhBM7saV0myZQgiHpk/FiNxCwom1mBMUgQmaXB8p7CGM7\n5gr/I/xMH6Rj2EedKCpCr3KMONC1OYKUY+VJEbNiIZX+99uBFyXeacMgyC033fhY\nnhG5yj+2JuW8HDU4C0SCpHBi+VhN6ffc7VR/QEfT3HKda/6WZKndrhbDCqWE/I0a\n3NfKO4C5VsFputzzpp9p7Rzr4xzvojZg05QXUDCoAQKBgQD8i8TZtoeu9UbIllVj\n7wDpwVII8fyWztCWsiuABQd1aOUOBmUUC+LcJiBFSvIe0y02RDi7HWJtv4MAZWDr\nZNhdXU/PCh3cAzyVjLxDrYS8DEF0h8Za1fkXs3UYY2nG3WNqQEo1ZFhF0MTqm9YX\nILE9U2N+C+gpF2QyUMb7+BZVlQKBgQDYAob7RHELGbYC+w7eZN1NKIFdpWbH4njO\nTRX/iE/jRPtmV7Cgpf+LxDnZ2feq3V0x5PP1dQ9z5XhSD89VIbARXfBBjW/iE5VW\nvc6CjKr44FIDCUR5vjkQjWk8GTULm7ZTt59JhHnJ+XQtI89lMeUJ2hOkFFUo9GNR\nd5Py+bRiAQKBgCznmU/w4b1dRYHDIVnMlIf75N9MT9Js4a/57DwuKL5asWfGAVEI\nMAVfDhvkEJskh4R/quqydd73z45ReGNCoiovvlIdBWQqeypIRO1vvAtHzpeu0Lk0\nFL9/HFIC0zsWAGhTGB7YQc3gKjNhFDc2i+1Ql39BFL3BuAIuVMNWwHnlAoGAEGko\nviA2AmTiqhlOyOCa24jPQ0EUrOzsxqeemzpM73RHMUBKP/o8ju7Kgl2H7mhA81B0\npFpPYTu2x21CEDKuALPFVAWd0WwxdVSYQtzTBHNuZ6KlnCYyiapkq1cy633Z/UQ/\nCsPQyOJ1zBQjZonC39u8kEOnMKRYg1D1YYlNBgECgYAMngapC7qsqBuc8AQFbVcz\nrLxLspRyH84v+9zdfeFAClkQjE42QK+a7nJPsXJHujuq+4XdU8TRFcn/dyEvYsYo\nVM2LzbrnIy4lev64UP2qqwPIOupHZ4C4HRK/xRl0Fno5bGlCqiflCcRZ6HLwMKw2\nCH8bJjJbGTyLrGBAKwKeYQ==\n-----END PRIVATE KEY-----\n",
      "client_email": "chatting-app-2-8e7d4@appspot.gserviceaccount.com",
      "client_id": "102013216710225577477",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/chatting-app-2-8e7d4%40appspot.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
            clientCredentials)
        , scopes);
    return client.credentials.accessToken.data;
  }
}