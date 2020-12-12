#include <iostream>
//Без этого pthread не заработал
#define HAVE_STRUCT_TIMESPEC
#include <pthread.h>
#include <semaphore.h>
#include <windows.h>
#include <chrono>
#include <string>
#include <vector>

//Без этого pthread не заработал
#pragma comment(lib,"pthreadVC2.lib")

using namespace std;

int numOfClients;
vector<bool> isWaiting;
pthread_mutex_t comeIn;

void* Client(void* args){
    auto start = chrono::system_clock::now();
    auto end = std::chrono::system_clock::now();
    int num = *((int*)args);
    srand(time(0) + num);
    int sleepTime = 1000 + (rand() % 40) * 100;
    Sleep(sleepTime);
    isWaiting.push_back(true);
    bool hadHaircut = false;
    while ((std::chrono::duration_cast<std::chrono::seconds>(end - start).count() <= 30) && !hadHaircut) {
        pthread_mutex_lock(&comeIn);
        cout << "Client " << num << " is having a new haircut." << endl;
        hadHaircut = true;
        isWaiting.pop_back();
        pthread_mutex_unlock(&comeIn);
        end = std::chrono::system_clock::now();
    }
    return NULL;
}

void* Barber(void* args) {
    auto start = chrono::system_clock::now();
    auto end = std::chrono::system_clock::now();
    while ((std::chrono::duration_cast<std::chrono::seconds>(end - start).count() <= 30)) {
        if (isWaiting.size() == 0) {
            pthread_mutex_lock(&comeIn);
            cout << "Barber is sleeping" << endl;
            Sleep(1000);
            pthread_mutex_unlock(&comeIn);
        }
        end = std::chrono::system_clock::now();
    }
    return NULL;
}


int main(int argc, char* argv[])
{
    if (argc != 2)
    {
        cout << "Something went wrong..." << endl;
        return -1;
    }
    try {
        numOfClients = stoi(argv[1]);
        if (numOfClients <= 0) {
            numOfClients = 1;
        }
    }
    catch (exception e) {
        cout << "Incorrect data";
        return -1;
    }
    
    pthread_mutex_init(&comeIn, nullptr);
    int* clNumber = new int[numOfClients];
    vector<pthread_t> clients(numOfClients);
    pthread_t barber;
    pthread_create(&barber, NULL, Barber, NULL);
    for (int t = 0; t < numOfClients; t++) {
        clNumber[t] = t + 1;
        pthread_create(&clients[t], NULL, Client, &clNumber[t]);
    }
    for (int t = 0; t < numOfClients; t++) {
        pthread_join(clients[t], NULL);
    }
    delete[] clNumber;
    pthread_join(barber, NULL);
}
