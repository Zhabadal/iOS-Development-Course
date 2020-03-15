//
//  ABDirectoryTableVC.m
//  33.FileManager HW3
//
//  Created by Александр on 18.02.2020.
//  Copyright © 2020 Badmaev. All rights reserved.
//

#import "ABDirectoryTableVC.h"
#import "ABFileCell.h"

@interface ABDirectoryTableVC ()

@property (strong, nonatomic) NSArray* contents;
@property (strong, nonatomic) NSArray* foldersContents;
@property (assign, nonatomic) unsigned long long fileSize;

@end

@implementation ABDirectoryTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //если path не установлен где-либо еще, устанавливаем его
    if (!self.path) {
        self.path = @"/Users/aleksandr/Downloads";
    }
}

//переопределенный сеттер для path, сделан для уверенности в том, что актуальный path установлен в self.path и данные переданы в таблицу
//как только устанавливается путь, сразу создается массив self.contents, которые содержит строки с именами файлов и папок по этому пути. Запускается метод removeHiddenFile, для удаления из массива элементов которые являются скрытыми файлами (по условию имя таких файлов начинается на "."). Также запускается метод [self sortContents:self.contents]; сортирующий данные
- (void)setPath:(NSString *)path {
    _path = path;
    
    NSError* error = nil;
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
                                                                        error:&error];
    self.contents = [self removeHiddenFiles:self.contents];
    [self sortContents:self.contents];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    self.navigationItem.title = [path lastPathComponent];
    
    [self.tableView reloadData];
}

#pragma mark - Data

//удаляет из массива элементы которые указывают на скрытые файлы
- (NSArray*)removeHiddenFiles:(NSArray*)contents {
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:contents];
    for (NSString* name in contents) {
        if ([self nameBelongToHiddenFile:name]) {
            [tempArray removeObject:name];
        }
    }
    contents = tempArray;
    return contents;
}

//если имя файла начинается на ".", считать его скрытым файлом
- (BOOL)nameBelongToHiddenFile:(NSString*)file {
    BOOL isHidden = NO;
    NSRange dotRange = [file rangeOfString:@"."];
    if (dotRange.location == 0) {
        isHidden = YES;
    }
    return isHidden;
}

//сортировка массива: в начале по типу файл или папка, затем по имени
- (void)sortContents:(NSArray*)contents {
    NSMutableArray* folderArray = [NSMutableArray array];
    NSMutableArray* fileArray = [NSMutableArray array];
    
    for (int i = 0; i < [contents count]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        if ([self isDirectoryAtIndexPath:indexPath]) {
            [folderArray addObject:[contents objectAtIndex:i]];
        } else {
            [fileArray addObject:[contents objectAtIndex:i]];
        }
    }
    
    NSArray* sortedFolderArray = [folderArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    self.foldersContents = sortedFolderArray;
    NSArray* sortedFileArray = [fileArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    NSArray* sortedArray = [sortedFolderArray arrayByAddingObjectsFromArray:sortedFileArray];
    self.contents = sortedArray;
}

//является ли строка по indexPath папкой
- (BOOL)isDirectoryAtIndexPath:(NSIndexPath*)indexPath {
    BOOL isDirectory = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:[self returnPathNameAtIndexPath:indexPath]
                                         isDirectory:&isDirectory];
    
    return isDirectory;
}

//возвращает path = добавляет к self.path имя файла/папки по indexPath
- (NSString*)returnPathNameAtIndexPath:(NSIndexPath*)indexPath {
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    NSString* path = [self.path stringByAppendingPathComponent:fileName];
    return path;
}

//создает новую папку в текущем расположении с именем folderName. Обновляет данные в массиве self.contents и обновляет таблицу, для правильного отображения данных в ней
- (void)createNewFolderWithName:(NSString*)folderName {
    //проверка на занятое имя папки
    BOOL matchFound = NO;
    
    for (NSString* name in self.foldersContents) {
        //сравнение без учета регистра символов
        if ([folderName caseInsensitiveCompare:name] == NSOrderedSame) {
            matchFound = YES;
        }
    }
    
    if (matchFound) {
        [self nameUsedAlert:folderName];
    } else {
        
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];
        NSUInteger indexForNewFolder = 0;
        [tempArray insertObject:folderName atIndex:indexForNewFolder];
        self.contents = tempArray;
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:indexForNewFolder inSection:indexForNewFolder];
        NSError* folderIsNotCreated = nil;
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:[self returnPathNameAtIndexPath:indexPath]
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&folderIsNotCreated]) {
            NSLog(@"%@", folderIsNotCreated);
        }
        
        [self sortContents:self.contents];
        
        [self.tableView performBatchUpdates:^{
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } completion:^(BOOL finished) {
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Auxiliary Methods

- (NSString*)fileSizeFromValue:(unsigned long long)size {
    static NSString* units[] = {@"B", @"Kb", @"Mb", @"Gb", @"Tb"};
    static int unitsCount = 5;
    int index = 0;
    double fileSize = (double)size;
    while (fileSize > 1000 && index < unitsCount) {
        fileSize /= 1000;
        index++;
    }
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
}

- (unsigned long long)calculateFolderSize:(NSString*)path {
    
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (isDirectory) {
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        
        for (NSString* contentName in contents) {
            NSString* deepPath = [path stringByAppendingPathComponent:contentName];
            [self calculateFolderSize:deepPath];
        }
    } else {
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        self.fileSize += [attributes fileSize];
    }
    return self.fileSize;
}

#pragma mark - Actions

//реализация кнопки Add в RightBarButtonItems. Создает Alert с textField для ввода имени новой папки
- (IBAction)actionAddFolder:(UIBarButtonItem*)sender {
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"New Folder"
                                                            message:@"Please enter name for new folder"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    UIAlertAction* alertCancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                style:UIAlertActionStyleCancel
                                                              handler:nil];
    
    UIAlertAction* alertNewFolderAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
        UITextField* newFolderNameTextField = [alertController.textFields objectAtIndex:0];
        NSString* folderName = newFolderNameTextField.text;
        [self createNewFolderWithName:folderName];
    }];
    
    [alertController addAction:alertCancelAction];
    [alertController addAction:alertNewFolderAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Alerts

//создание предупреждения, что имя уже используется. Вызывает заново метод [self actionAddFolder:nil];
- (void)nameUsedAlert:(NSString*)name {
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"The name '%@' is already taken. Please choose different name.", name] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* alertNewFolderAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddFolder:nil];
    }];
    [alertController addAction:alertNewFolderAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

//реализует нажатие на строку с папкой
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        ABDirectoryTableVC* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ABDirectoryTableVC"];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//изменяет высоту строки
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        return 50.f;
    } else {
        return 60.f;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents count];
}

//создание строк двух типов для папок и для файлов
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        static NSString* folderCellIdentifier = @"FolderCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:folderCellIdentifier
                                                                forIndexPath:indexPath];
        self.fileSize = 0;
        unsigned long long folderSize = [self calculateFolderSize:[self returnPathNameAtIndexPath:indexPath]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self fileSizeFromValue:folderSize]];
        cell.textLabel.text = fileName;
        return cell;
        
    } else {
        
        static NSString* fileCellIdentifier = @"FileCell";
        ABFileCell* cell = [tableView dequeueReusableCellWithIdentifier:fileCellIdentifier
                                                           forIndexPath:indexPath];
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        cell.fileName.text = fileName;
        cell.fileSize.text = [NSString stringWithFormat:@"%@", [self fileSizeFromValue:[attributes fileSize]]];
        return cell;
    }
}

//реализация удаления файла или папки
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[NSFileManager defaultManager] removeItemAtPath:[self returnPathNameAtIndexPath:indexPath] error:nil];
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];
        [tempArray removeObjectAtIndex:indexPath.row];
        self.contents = tempArray;
        [tableView performBatchUpdates:^{
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } completion:^(BOOL finished) {
        }];
    }
}

@end
