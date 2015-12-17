//
//  DUBLayout.m
//  DUfreeBandA
//
//  Created by FLY_AY on 15/12/4.
//  Copyright © 2015年 FLY_AY. All rights reserved.
//

#import "DUBLayout.h"

@implementation DUBLayout

-(instancetype)init
{
    if (self = [super init]) {
        
        self.sectionInset = UIEdgeInsetsMake(8, 0.0, 0, 0.0);
        
    }
    return self;
    
}


- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    UICollectionView * const cv = self.collectionView;
    CGPoint const contentOffset = cv.contentOffset;
    
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }
    
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        
        [answer addObject:layoutAttributes];
        
    }];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
            
            NSIndexPath *firstObjectIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
            
            UICollectionViewLayoutAttributes *firstObjectAttrs;
            UICollectionViewLayoutAttributes *lastObjectAttrs;
            
            if (numberOfItemsInSection > 0) {
                firstObjectAttrs = [self layoutAttributesForItemAtIndexPath:firstObjectIndexPath];
                lastObjectAttrs = [self layoutAttributesForItemAtIndexPath:lastObjectIndexPath];
            }
            else {
//                firstObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                                                                        atIndexPath:firstObjectIndexPath];
//                lastObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
//                                                                       atIndexPath:lastObjectIndexPath];
//                if (lastObjectAttrs == nil) {
//                    lastObjectAttrs = firstObjectAttrs;
//                }
                //cell没值,就新建一个UICollectionViewLayoutAttributes
                firstObjectAttrs = [UICollectionViewLayoutAttributes new];
                //然后模拟出在当前分区中的唯一一个cell，cell在header的下面，高度为0，还与header隔着可能存在的sectionInset的top
                CGFloat y = CGRectGetMaxY(layoutAttributes.frame)+self.sectionInset.top;
                firstObjectAttrs.frame = CGRectMake(0, y, 0, 0);
                //因为只有一个cell，所以最后一个cell等于第一个cell
                lastObjectAttrs = firstObjectAttrs;
            }
            
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
                CGPoint origin = layoutAttributes.frame.origin;
                origin.y = MIN(MAX(contentOffset.y, (CGRectGetMinY(firstObjectAttrs.frame) - headerHeight - self.sectionInset.top)),(CGRectGetMaxY(lastObjectAttrs.frame) - headerHeight + self.sectionInset.bottom));
                
                layoutAttributes.zIndex = 1024;
                layoutAttributes.frame = (CGRect){
                    .origin = origin,
                    .size = layoutAttributes.frame.size
                };
                
                
                
            }
            else {
                CGFloat headerWidth = CGRectGetWidth(layoutAttributes.frame);
                CGPoint origin = layoutAttributes.frame.origin;
                origin.x = MIN(
                               MAX(contentOffset.x, (CGRectGetMinX(firstObjectAttrs.frame) - headerWidth)),
                               (CGRectGetMaxX(lastObjectAttrs.frame) - headerWidth)
                               );
                
                layoutAttributes.zIndex = 1024;
                layoutAttributes.frame = (CGRect){
                    .origin = origin,
                    .size = layoutAttributes.frame.size
                };
            }
            
        }
        
    }
    
    return answer;
    
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    
    return YES;
    
}

@end
