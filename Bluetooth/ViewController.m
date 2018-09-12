//
//  ViewController.m
//  Bluetooth
//
//  Created by danlan on 2018/9/11.
//  Copyright © 2018 lee. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define KLServiceUUID  @"约定好的蓝牙设备的服务ID"
#define KLCharacteristicWriteUUID  @"约定好的蓝牙设备的写入特征ID"
#define KLCharacteristicNotifyUUID  @"约定好的蓝牙设备的notify特性"

/**
 *
 
 * https://my.oschina.net/linweida/blog/749317 这个人博客讲的挺好的,特别详细
 
 * http://liuyanwei.jumppo.com/2015/08/14/ios-BLE-2.html 蓝牙开发，读写数据
 
 * https://remember17.github.io/2017/07/18/iOS蓝牙开发，中心设备和外设的实现，有Demo/ 两个 设备互发信息
 * http://liuyanwei.jumppo.com/2017/05/16/JavaScript-mqtt-temperaturedemo.html
 * https://juejin.im/entry/58f70ecb61ff4b0058111df0
 *
 * https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/BestPracticesForInteractingWithARemotePeripheralDevice/BestPracticesForInteractingWithARemotePeripheralDevice.html
 
 * https://developer.apple.com/accessories/Accessory-Design-Guidelines.pdf
 
 * https://www.jianshu.com/p/1bab18e4195b 几个特征值
 * https://www.jianshu.com/p/86c8ac4c5f29
 * https://juejin.im/entry/587b2c6b128fe10057f1bfc5
 */

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableArray *peripheralList;

@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) CBCharacteristic *characteristicWrite;
@property (nonatomic, strong) CBCharacteristic *characteristicNotify;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheralList = [NSMutableArray array];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"currentUUID : %@", uuid);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"central.state  %@", @(central.state));
    if (central.state == CBManagerStatePoweredOn) {
        //网上有说 使用固定的serviceUUID 容易找不到，最好传nil
        //查询所有的然后过滤
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    /**
     
     在ios中蓝牙广播信息中通常会包含以下4种类型的信息。ios的蓝牙通信协议中不接受其他类型的广播信息。因此需要注意的是，如果需要在扫描设备时，通 过蓝牙设备的Mac地址来唯一辨别设备，那么需要与蓝牙设备的硬件工程师沟通好：将所需要的Mac地址放到一下几种类型的广播信息中。通常放到 kCBAdvDataManufacturerData这个字段中。
        kCBAdvDataIsConnectable = 1;
        kCBAdvDataLocalName = XXXXXX;
        kCBAdvDataManufacturerData = <XXXXXXXX>;
        kCBAdvDataTxPowerLevel = 0
     
        advertisementData[@"kCBAdvDataManufacturerData"]
        我看有设备在这里存放Mac地址的
     
        设备的UUID（peripheral.identifier）是由两个设备的mac通过算法得到的，所以不同的手机连接相同的设备，它的UUID都是不同的，无法标识设备
     
        苹果与蓝牙设备连接通信时，使用的并不是苹果蓝牙模块的Mac地址，使用的是苹果随机生成的十六进制码作为手机蓝牙的Mac与外围蓝牙设备进行交互。如果 蓝牙设备与手机在一定时间内多次通信，那么使用的是首次连接时随机生成的十六进制码作为Mac地址，超过这个固定的时间段，手机会清空已随机生成的Mac 地址，重新生成。也就是说外围设备是不能通过与苹果手机的交互时所获取的蓝牙Mac地址作为手机的唯一标识的
     */
    
    NSLog(@"peripheral dicoveryed, advertisementData: %@", advertisementData);
    if (!peripheral.name) {
        return;
    }
    NSLog(@"peripheral dicoveryed, %@", peripheral.name);
    /*
    if (![self.peripheralList containsObject:peripheral]) {
        [self.peripheralList addObject:peripheral];
    }*/
    /*
     
     2018-09-11 11:26:08.091986+0800 Bluetooth[9997:4680694] peripheral dicoveryed, Mi Band 3
     2018-09-11 11:26:08.092522+0800 Bluetooth[9997:4680694] peripheral dicoveryed, Mi Band 3
     2018-09-11 11:26:09.802289+0800 Bluetooth[9997:4680694] peripheral dicoveryed, MI Band 2
     2018-09-11 11:26:09.802856+0800 Bluetooth[9997:4680694] peripheral dicoveryed, MI Band 2
     2018-09-11 11:26:12.426442+0800 Bluetooth[9997:4680694] peripheral dicoveryed, LE-reserved_Q
     2018-09-11 11:26:19.723025+0800 Bluetooth[9997:4680694] peripheral dicoveryed, mobike
     2018-09-11 11:26:22.921029+0800 Bluetooth[9997:4680694] peripheral dicoveryed, LE-Puma
     2018-09-11 11:26:22.921435+0800 Bluetooth[9997:4680694] peripheral dicoveryed, LE-Puma
     2018-09-11 11:26:26.739336+0800 Bluetooth[9997:4680694] peripheral dicoveryed, LE-reserved_Q
     2018-09-11 11:26:43.735426+0800 Bluetooth[9997:4680694] peripheral dicoveryed, mobike
     
    */
    //中间不停的回调，我们需要做的是 要不就是，只是展示，或者自己根据特定名字什么的进行连接
    
    
    // 也有读取 advertisementData 里的  kCBAdvDataLocalName 进行判断的，比如名字
    if ([advertisementData[@"kCBAdvDataLocalName"] hasPrefix:@""]) {
        self.connectedPeripheral = peripheral;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //连接成功
    //一般在这里停止扫描
    [self.centralManager stopScan];
    
    
    NSLog(@"didConnectPeripheral:%@", peripheral.name);
    peripheral.delegate = self;
    //这个ServiceUUID，蓝牙设备提供服务的UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:KLServiceUUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //连接失败
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //断开连接
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // 外设发现服务回调，
    if (error) {
        NSLog(@"didDiscoverServices error : %@", [error localizedDescription]);
        return;
    }
    
    // 遍历设备提供的服务
    for (CBService *service in peripheral.services) {
        //NSLog(@"service's uuid : %@", service.UUID);
        
        // 找到需要的服务，并获取该服务响应的特性
        if ([service.UUID isEqual:[CBUUID UUIDWithString:KLServiceUUID]]) {
            [service.peripheral discoverCharacteristics:nil forService:service];
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    // 外围设备发现特性回调
    if (error) {
        // 输出错误信息
        NSLog(@"didDiscoverCharacteristicsForService, error: %@", [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:KLCharacteristicWriteUUID]]) {
            //把读写属性存储下来
            self.characteristicWrite = characteristic;
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:KLCharacteristicNotifyUUID]]) {
            
            //存储需要订阅的特性
            self.characteristicNotify = characteristic;
            [self.connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"error = %@", [error localizedDescription]);
    }
    // 对特性KLCharacteristicNotifyUUID设置notify(订阅)，成功以后回调
    if ([characteristic.UUID.UUIDString isEqualToString:KLCharacteristicNotifyUUID] && characteristic.isNotifying) {
        // 写数据 回调-didWriteValueForCharacteristic
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 外围设备数据更新回调， 可以在此回调方法中读取信息（无论是read的回调，还是notify（订阅）的回调都是此方法）
    if (error) {
        // 输出错误信息
        NSLog(@"didUpdateValueForCharacteristic, error: %@", [error localizedDescription]);
        return;
    }
    // 解析数据
    NSData *data = characteristic.value;
    
    // 将NSData转Byte数组
    NSUInteger len = [data length];
    Byte *byteData = (Byte *)malloc(len);
    memcpy(byteData, [data bytes], len);
    NSMutableArray *commandArray = [NSMutableArray arrayWithCapacity:0];
    // Byte数组转字符串
    for (int i = 0; i < len; i++) {
        NSString *str = [NSString stringWithFormat:@"%02x", byteData[i]];
        [commandArray addObject:str];
        NSLog(@"byteData = %@", str);
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    //特性已写入外围设备的回调(如果写入类型为CBCharacteristicWriteWithResponse 回调此方法，如果写入类型为CBCharacteristicWriteWithoutResponse不回调此方法)
    if (error) {
        NSLog(@"write.error=======%@",error.userInfo);
    }
    
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    
    // 读数据
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:KLCharacteristicWriteUUID]]) {
        [self readCharacter];
    }
}

- (void)writeCharacter:(NSData *)data {
    //对某个特性写入数据
    if ([self.characteristicWrite.UUID isEqual:[CBUUID UUIDWithString:KLCharacteristicWriteUUID]]) {
        [self.connectedPeripheral writeValue:data forCharacteristic:self.characteristicWrite type:CBCharacteristicWriteWithResponse];
    } else {
        [self.connectedPeripheral writeValue:data forCharacteristic:self.characteristicWrite
                                  type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)readCharacter {
    [self.connectedPeripheral readValueForCharacteristic:self.characteristicWrite];
}

@end

















