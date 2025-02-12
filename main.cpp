#include "pch.h"

using nlohmann::json;

std::vector<std::bitset<8>> toBinary(std::string s) {
	std::vector<std::string> strings;

	//split ip and subnetmask into octets
	for (auto&& octet : std::views::split(s, '.')) {
		strings.push_back(std::string(octet.begin(), octet.end()));
	}
	
	std::vector<std::bitset<8>> octs;
	
	//convert octet strings to binary
	for (std::string s : strings) {
		int num = std::stoi(s);
		octs.push_back(std::bitset<8>(num));
	}

	return octs;
}

int calcHosts(std::string mask) {
	int hostBits = 0;

	//count host bits
	for (std::bitset<8>&s : toBinary(mask)) {
		hostBits += 8 - s.count();
	}

	//calc num of hosts
	return std::max(0, (int) pow(2, hostBits) - 2);
}

std::vector<std::bitset<8>> calcNetaddress(std::string& ip, std::string& mask) {
	//convert ip and mask to binary
	std::vector<std::bitset<8>> ipBits = toBinary(ip);
	std::vector<std::bitset<8>> maskBits = toBinary(mask);

	std::vector<std::bitset<8>> netID{};

	//calculates Netaddress
	for (int i = 0; i < 4; i++) {
		netID.push_back(ipBits[i] & maskBits[i]);
	}

	return netID;
}

std::vector<std::bitset<8>> calcBroadcast(std::string& ip, std::string& mask) {
	//convert ip and mask to binary
	std::vector<std::bitset<8>> ipBits = toBinary(ip);
	std::vector<std::bitset<8>> maskBits = toBinary(mask);

	std::vector<std::bitset<8>> broadcastID{};

	//calculates Broadcastaddress
	for (int i = 0; i < 4; i++) {
		maskBits[i].flip();
		broadcastID.push_back(ipBits[i] | maskBits[i]);
	}

	return broadcastID;
}

std::string printBinary(std::vector<std::bitset<8>> binary) {
	std::string output;

	//convert bitset to string
	for (auto& octet : binary) {
		output.append(octet.to_string() + '.');
	}
	output.resize(output.size() - 1);
	return output;
}

std::string printDecimal(std::vector<std::bitset<8>> binary) {
	std::string output;
	//convert bitset to int to string
	for (auto& octet : binary) {
		output.append(std::to_string(octet.to_ulong()) + '.');
	}
	output.resize(output.size() - 1);
	return output;
}


int main() {

	json ips;
	std::string file = "ips.json";

	//open stream to read
	std::fstream stream(file, std::ios::in);
	if (!stream.is_open()) {
		std::cerr << "failed to open " << file << std::endl;
		return 0;
	}

	stream >> ips;

	//Read Input from json
	std::string ip = ips["Input"]["IPAddress"];
	std::string mask = ips["Input"]["SubnetMask"];

	//validate ip and mask
	if (!std::regex_match(ip, IPPattern) || std::find(MaskPattern.begin(), MaskPattern.end(), mask) == MaskPattern.end()) {
		std::cout << "invalid ip or subnetmask";
		return 0;
	}

	stream.close();

	//calculate netaddress and broadcastaddress
	std::vector<std::bitset<8>> netAddress = calcNetaddress(ip, mask);
	std::vector<std::bitset<8>> broadcast = calcBroadcast(ip, mask);

	//open stream to write
	stream.open(file, std::ios::out);

	//prepare output to json
	ips["Output"]["HostCount"] = std::to_string( calcHosts(mask) );
	ips["Output"]["NetworkAddress"] = printDecimal( netAddress );
	ips["Output"]["NetworkBinary"] = printBinary( netAddress );
	ips["Output"]["BroadcastAddress"] = printDecimal( broadcast );
	ips["Output"]["BroadcastBinary"] = printBinary( broadcast );
	ips["Output"]["SubnetMaskBinary"] = printBinary( toBinary(mask) );
	ips["Output"]["IPBinary"] = printBinary( toBinary(ip) );

	//write to json
	stream << ips.dump(2);

	stream.close();

}