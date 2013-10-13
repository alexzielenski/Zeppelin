//
//  UDTableView.m
//
// Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "UDTableView.h"

@interface UITableView (Private)
- (NSArray *)indexPathsForSelectedRows;
@end

@interface UDTableView (UDPrivate)

- (void)ud_setAllowsMultipleSelectionDuringEditing:(BOOL)allowsMultipleSelectionDuringEditing;
- (BOOL)ud_allowsMultipleSelectionDuringEditing;
- (void)ud_setAllowsMultipleSelection:(BOOL)allowsMultipleSelection;
- (BOOL)ud_allowsMultipleSelection;

@end


@implementation UDTableView

#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_indexPathsForSelectedRows release];
    [super dealloc];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if( (self = [super initWithCoder:aDecoder]) ){
        [self setAllowsMultipleSelectionDuringEditing: [aDecoder decodeBoolForKey:@"UIAllowsMultipleSelectionDuringEditing"]];
        [self setAllowsMultipleSelection: [aDecoder decodeBoolForKey:@"UIAllowsMultipleSelection"]];
    }
    return self;
}


- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ( [_realDataSource respondsToSelector:aSelector] ){
        return _realDataSource;
    }else if ( [_realDelegate respondsToSelector:aSelector] ){
        return _realDelegate;
    }
    return self;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSString *aSelectorString = NSStringFromSelector(aSelector);
    
    if( [aSelectorString isEqualToString:@"setAllowsMultipleSelectionDuringEditing:"] ){
        return [[self class] instanceMethodSignatureForSelector:@selector(ud_setAllowsMultipleSelectionDuringEditing:)];   
    }else if( [aSelectorString isEqualToString:@"allowsMultipleSelectionDuringEditing"] ){
        return [[self class] instanceMethodSignatureForSelector:@selector(ud_allowsMultipleSelectionDuringEditing)];   
    }else if( [aSelectorString isEqualToString:@"setAllowsMultipleSelection:"] ){
        return [[self class] instanceMethodSignatureForSelector:@selector(ud_setAllowsMultipleSelection:)];   
    }else if( [aSelectorString isEqualToString:@"allowsMultipleSelection"] ){
        return [[self class] instanceMethodSignatureForSelector:@selector(ud_allowsMultipleSelection)];   
    }

    return nil;
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *aSelectorString = NSStringFromSelector([invocation selector]);
    
    if( [aSelectorString isEqualToString:@"setAllowsMultipleSelectionDuringEditing:"] ){
        [invocation setSelector:@selector(ud_setAllowsMultipleSelectionDuringEditing:)];
        [invocation invokeWithTarget:self];
    }else if( [aSelectorString isEqualToString:@"allowsMultipleSelectionDuringEditing"] ){
        [invocation setSelector:@selector(ud_allowsMultipleSelectionDuringEditing)];
        [invocation invokeWithTarget:self];
    }else if( [aSelectorString isEqualToString:@"setAllowsMultipleSelection:"] ){
        [invocation setSelector:@selector(ud_setAllowsMultipleSelection:)];
        [invocation invokeWithTarget:self];
    }else if( [aSelectorString isEqualToString:@"allowsMultipleSelection"] ){
        [invocation setSelector:@selector(ud_allowsMultipleSelection)];
        [invocation invokeWithTarget:self];
    }else{
        [self doesNotRecognizeSelector:[invocation selector]];
    }
}


- (BOOL)respondsToSelector:(SEL)aSelector {
    return ( [super respondsToSelector:aSelector] || [_realDataSource respondsToSelector:aSelector] || [_realDelegate respondsToSelector:aSelector] );
}


- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return ( [super conformsToProtocol:aProtocol] || [_realDataSource conformsToProtocol:aProtocol] || [_realDelegate conformsToProtocol:aProtocol] );
}


#pragma mark -
#pragma mark UITableView


- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    _realDataSource = dataSource;
    if( _needsMultipleSelectionBackport ){
        [super setDataSource:(id<UITableViewDataSource>)self];
    }else{
        [super setDataSource:dataSource];
    }
}


- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    _realDelegate = delegate;
    if( _needsMultipleSelectionBackport ){
        [super setDelegate:(id<UITableViewDelegate>)self];
    }else{
        [super setDelegate:delegate];
    }
}


- (void)reloadData {
    for( NSIndexPath *indexPath in [_indexPathsForSelectedRows allObjects] ){
        [self deselectRowAtIndexPath:indexPath animated:NO];
    }
    [_indexPathsForSelectedRows removeAllObjects];
    
    [super reloadData];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    for( NSIndexPath *indexPath in [_indexPathsForSelectedRows allObjects] ){
        [self deselectRowAtIndexPath:indexPath animated:NO];
    }
    [_indexPathsForSelectedRows removeAllObjects];
    
    [super setEditing:editing animated:animated];
}


- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    
    if( _needsMultipleSelectionBackport && indexPath && ((_allowsMultipleSelectionDuringEditing && self.isEditing) || (_allowsMultipleSelection && !self.isEditing)) ){
        // NSAssert(( &UIApplicationLaunchOptionsNewsstandDownloadsKey == NULL ), @"tselectRowAtIndexPath:animated:scrollPosition: shouldn't be called because iOS5+ natively supports multiselect");
        
        [_indexPathsForSelectedRows addObject:indexPath];
        [[self cellForRowAtIndexPath:indexPath] setSelected:YES animated:animated];
    }else{
        [super selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    }
    
}


- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
 
    if( _needsMultipleSelectionBackport && indexPath && ((_allowsMultipleSelectionDuringEditing && self.isEditing) || (_allowsMultipleSelection && !self.isEditing)) ){
        // NSAssert(( &UIApplicationLaunchOptionsNewsstandDownloadsKey == NULL ), @"deselectRowAtIndexPath:animated: shouldn't be called because iOS5+ natively supports multiselect");
        NSLog(@"remove it");
        [_indexPathsForSelectedRows removeObject:indexPath];
        [[self cellForRowAtIndexPath:indexPath] setSelected:NO animated:animated];
    }else {
        [super deselectRowAtIndexPath:indexPath animated:animated];
    }
    
}


- (void)setAllowsSelection:(BOOL)allowsSelection {
    [super setAllowsSelection:allowsSelection];
    if( _needsMultipleSelectionBackport && ![self allowsSelection] ){
        [self setAllowsMultipleSelection:NO];
    }
}


- (void)setAllowsSelectionDuringEditing:(BOOL)allowsSelectionDuringEditing {
    [super setAllowsSelectionDuringEditing:allowsSelectionDuringEditing];
    if( _needsMultipleSelectionBackport && ![self allowsSelectionDuringEditing] ){
        [self setAllowsMultipleSelectionDuringEditing:NO];
    }
}


#pragma mark -
#pragma mark UITableViewDelegate


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSAssert(( &UIApplicationLaunchOptionsNewsstandDownloadsKey == NULL ), @"tableView:cellForRowAtIndexPath: shouldn't be called because iOS5+ natively supports multiselect");
    
    if( [_indexPathsForSelectedRows containsObject:indexPath] ){
        [cell setSelected:YES];
    }
    if ( [_realDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)] ){
        [_realDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSAssert(( &UIApplicationLaunchOptionsNewsstandDownloadsKey == NULL ), @"tableView:willSelectRowAtIndexPath: shouldn't be called because iOS5+ natively supports multiselect");
    if( [_indexPathsForSelectedRows containsObject:indexPath] ){
        
        [self deselectRowAtIndexPath:indexPath animated:NO];
    	if( [_realDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)] ){
            [_realDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
        }        
    }else{
        [self selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        if( [_realDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)] ){
            [_realDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
    }
    return nil;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSAssert(( &UIApplicationLaunchOptionsNewsstandDownloadsKey == NULL ), @"tableView:willDeselectRowAtIndexPath: shouldn't be called because iOS5+ natively supports multiselect");
    
    return nil;
}


#pragma mark -
#pragma mark UDTableView


- (void)ud_setAllowsMultipleSelectionDuringEditing:(BOOL)allowsMultipleSelectionDuringEditing {
    if( _allowsMultipleSelectionDuringEditing == allowsMultipleSelectionDuringEditing ) return;
    
    // NSAssert(( &UIApplicationLaunchOptionsNewsstandDownloadsKey == NULL ), @"ud_setAllowsMultipleSelectionDuringEditing: shouldn't be called because iOS5+ natively supports multiselect");
    
    _allowsMultipleSelectionDuringEditing = _needsMultipleSelectionBackport = allowsMultipleSelectionDuringEditing;
    if( _allowsMultipleSelectionDuringEditing ){
        [_indexPathsForSelectedRows release];
        _indexPathsForSelectedRows = [[NSMutableSet alloc] init];
        
        if( super.dataSource ) [super setDataSource:(id<UITableViewDataSource>)self];
        if( super.delegate ) [super setDelegate:(id<UITableViewDelegate>)self];

        [self setAllowsSelectionDuringEditing:YES];
    }else{
        [_indexPathsForSelectedRows release], _indexPathsForSelectedRows = nil;
        
        [self setDelegate:_realDelegate];
        [self setDataSource:_realDataSource];
    }
}


- (BOOL)ud_allowsMultipleSelectionDuringEditing {
    return _allowsMultipleSelectionDuringEditing;
}


- (void)ud_setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    if( _allowsMultipleSelection == allowsMultipleSelection ) return;
    
    // NSAssert(( &UIApplicationLaunchOptionsNewsstandDownloadsKey == NULL ), @"ud_setAllowsMultipleSelectionDuringEditing: shouldn't be called because iOS5+ natively supports multiselect");
    
    _allowsMultipleSelection = _needsMultipleSelectionBackport = allowsMultipleSelection;
    if( _allowsMultipleSelection ){
        [_indexPathsForSelectedRows release];
        _indexPathsForSelectedRows = [[NSMutableSet alloc] init];
        
        if( super.dataSource ) [super setDataSource:(id<UITableViewDataSource>)self];
        if( super.delegate ) [super setDelegate:(id<UITableViewDelegate>)self];
        
        [self setAllowsSelection:YES];
    }else{
        [_indexPathsForSelectedRows release], _indexPathsForSelectedRows = nil;
        
        [self setDelegate:_realDelegate];
        [self setDataSource:_realDataSource];
    }
}


- (BOOL)ud_allowsMultipleSelection {
    return _allowsMultipleSelection;
}



- (NSArray *)indexPathsForSelectedRows {
    if( _needsMultipleSelectionBackport ){
        return [_indexPathsForSelectedRows allObjects];
    }else{
        return [super indexPathsForSelectedRows];
    }
}


@dynamic allowsMultipleSelectionDuringEditing, allowsMultipleSelection;
@end
