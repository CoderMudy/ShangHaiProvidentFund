//
//  CDOpinionsSuggestionsController.m
//  ShangHaiProvidentFund
//
//  Created by Cheng on 16/5/7.
//  Copyright © 2016年 cheng dong. All rights reserved.
//

#import "CDOpinionsSuggestionsController.h"
#import "CDNormalTextFieldConfigureItem.h"
#import "CDOpinionsSuggestionsModel.h"
#import "CDOpinionsSuggestionsFieldCell.h"
#import "CDOpinionsSuggestionsViewCell.h"
#import "UITextField+cellIndexPath.h"
#import "UITextView+CDCategory.h"
#import "CDButtonTableFooterView.h"
#import "CDCommitMessageService.h"

static NSString *cellidentifier = @"cellidentifier";

@interface CDOpinionsSuggestionsController ()

@property (nonatomic, strong) CDOpinionsSuggestionsModel *opinionsSuggestionsModel;
@property (nonatomic, strong) CDButtonTableFooterView *footerView;
@property (nonatomic, strong) CDCommitMessageService *commitMessageService;

@end

@implementation CDOpinionsSuggestionsController

- (instancetype)init{
    self =[super init];
    if (self) {
        self.title=@"在线留言";
        self.tableViewStyle=UITableViewStyleGrouped;
        self.showDragView=NO;
        self.hideKeyboradWhenTouch=YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView=self.footerView;
    [self.tableView registerClass:[CDOpinionsSuggestionsFieldCell class] forCellReuseIdentifier:cellidentifier];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controlTextDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controlTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    if (self.commitMessageService.isLoading) {
        [self.commitMessageService cancel];
    }
}

- (CDButtonTableFooterView *)footerView{
    if(_footerView == nil){
        _footerView = [CDButtonTableFooterView footerView];
        [_footerView setupBtnTitle:@"提交"];
        __weak typeof(self) weakSelf=self;
        _footerView.buttonClickBlock=^(UIButton *sender){
            [weakSelf p_commitMessage];
        };
    }
    return _footerView;
}

- (CDOpinionsSuggestionsModel *)opinionsSuggestionsModel{
    if(_opinionsSuggestionsModel == nil){
        _opinionsSuggestionsModel = [[CDOpinionsSuggestionsModel alloc]init];
    }
    return _opinionsSuggestionsModel;
}

- (CDCommitMessageService *)commitMessageService{
    if(_commitMessageService == nil){
        _commitMessageService = [[CDCommitMessageService alloc]initWithDelegate:self];
    }
    return _commitMessageService;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.opinionsSuggestionsModel.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CDNormalTextFieldConfigureItem *item=[self.opinionsSuggestionsModel.arrData cd_safeObjectAtIndex:indexPath.row];
    if ([item.type isEqualToString:@"1"]) {
        static NSString *textViewCellIdentifier=@"textViewCellIdentifier";
        CDOpinionsSuggestionsViewCell *cell=[tableView dequeueReusableCellWithIdentifier:textViewCellIdentifier];
        if (!cell) {
            cell=[CDOpinionsSuggestionsViewCell textViewCell];
        }
        [cell setupCellItem:item indexPath:indexPath];
        return cell;
    }else{
        CDOpinionsSuggestionsFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
        [cell setupItem:item indexPath:indexPath];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CDNormalTextFieldConfigureItem *item=[self.opinionsSuggestionsModel.arrData cd_safeObjectAtIndex:indexPath.row];
    return ([item.type isEqualToString:@"1"]) ? 100 : 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 13;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark - CDJSONBaseNetworkServiceDelegate
- (void)serviceDidFinished:(CDJSONBaseNetworkService *)service{
    [super serviceDidFinished:service];
    if ([self.commitMessageService.type isEqualToString:@"1"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)service:(CDJSONBaseNetworkService *)service didFailLoadWithError:(NSError *)error{
    [super service:service didFailLoadWithError:error];
}

#pragma mark - override
- (void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    UIEdgeInsets insets=self.tableView.contentInset;
    insets.bottom=_keyboardBounds.size.height;
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [super keyboardWillHide:notification];
    [UIView animateWithDuration:_keybardAnmiatedTimeinterval animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (velocity.y<0) {
        [self.tableView endEditing:YES];
    }
}

#pragma mark - Notification
- (void)controlTextDidChange:(NSNotification *)noti{
    if ([noti.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = noti.object;
        CDNormalTextFieldConfigureItem *cellItem = [self.opinionsSuggestionsModel.arrData cd_safeObjectAtIndex:textField.indexPath.row];
        cellItem.value=textField.text;
    }else if ([noti.object isKindOfClass:[UITextView class]]){
        UITextView *textView = noti.object;
        CDNormalTextFieldConfigureItem *cellItem = [self.opinionsSuggestionsModel.arrData cd_safeObjectAtIndex:textView.indexPath.row];
        cellItem.value=textView.text;
    }
}

#pragma mark - private
- (void)p_commitMessage{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    for (CDNormalTextFieldConfigureItem *item in self.opinionsSuggestionsModel.arrData) {
        if (item.value.length==0) {
            [CDAutoHideMessageHUD showMessage:@"请输入必要信息"];
            return;
        }
        [dict cd_safeSetObject:item.value forKey:item.paramsubmit];
    }
    [self.commitMessageService loadWithParams:dict showIndicator:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
