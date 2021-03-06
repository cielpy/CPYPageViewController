//
//  CPYPageViewController.m
//  Pods
//
//  Created by ciel on 2017/4/2.
//
//

#import "CPYPageViewController.h"

@interface CPYPageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) CPYScrollView *scrollView;
@property (nonatomic, assign, readwrite) NSInteger selectedIndex;

@end

@implementation CPYPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self __setup];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupViewControllers];
    [self setupScrollView];
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.view.bounds) * self.selectedIndex, 0);
}

#pragma mark -setup

- (void)__setup {
    [self.view addSubview:self.scrollView];
    [self setupScrollView];
    self.selectedIndex = 0;
}

#pragma mark - setters

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    UIViewController *preViewController = self.viewControllers[_selectedIndex];
    if ([preViewController conformsToProtocol:@protocol(CPYPageViewControllerViewLifeCycle)] && [preViewController respondsToSelector:@selector(cpy_pageViewWillDisappear)]) {
        [preViewController performSelector:@selector(cpy_pageViewWillDisappear)];
    }
    
    _selectedIndex = selectedIndex;
    
    UIViewController *currentViewController = self.viewControllers[_selectedIndex];
    if ([currentViewController conformsToProtocol:@protocol(CPYPageViewControllerViewLifeCycle)] && [currentViewController respondsToSelector:@selector(cpy_pageViewWillAppear)]) {
        [currentViewController performSelector:@selector(cpy_pageViewWillAppear)];
    }
    
    if (!self.navigationController) {
        return;
    }
    if (_selectedIndex != 0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
        return;
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
}

#pragma mark - public

- (void)selectViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated {
    self.selectedIndex = index;
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.view.bounds) * index, 0) animated:animated];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    _viewControllers = viewControllers;
    [self setupViewControllers];
    if (_viewControllers.count) {
        UIViewController *currentViewController = self.viewControllers[0];
        if ([currentViewController conformsToProtocol:@protocol(CPYPageViewControllerViewLifeCycle)] && [currentViewController respondsToSelector:@selector(cpy_pageViewWillAppear)]) {
            [currentViewController performSelector:@selector(cpy_pageViewWillAppear)];
        }
    }
    [self setupScrollView];
}

#pragma mark - private

- (void)setupViewControllers {
    for (UIViewController *vc in self.childViewControllers) {
        [vc removeFromParentViewController];
        [vc.view removeFromSuperview];
    }
    
    for (int i = 0; i < self.viewControllers.count; i++) {
        [self addChildViewController:self.viewControllers[i]];
        [self.scrollView addSubview:self.viewControllers[i].view];
        self.viewControllers[i].view.frame = CGRectMake(i * CGRectGetWidth(self.view.bounds), 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        self.viewControllers[i].view.autoresizingMask = UIViewAutoresizingNone;
    }
}

- (void)setupScrollView {
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * self.viewControllers.count, CGRectGetHeight(self.view.bounds));
}

#pragma mark - getters

- (CPYScrollView *)scrollView {
	if (!_scrollView) {
        _scrollView = [[CPYScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
	}
	return _scrollView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / CGRectGetWidth(self.view.bounds);
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:didScrollToViewControllerAtIndex:)]) {
        self.selectedIndex = page;
        [self.delegate pageViewController:self didScrollToViewControllerAtIndex:page];
    }
}

#pragma mark - UIScrollViewDelegate forwarding

-(BOOL)respondsToSelector:(SEL)aSelector {
    NSString *selectorString = NSStringFromSelector(aSelector);
    if ([selectorString hasPrefix:@"scrollView"] && [self.scrollViewDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

-(id)forwardingTargetForSelector:(SEL)aSelector {
    NSString *selectorString = NSStringFromSelector(aSelector);
    if ([selectorString hasPrefix:@"scrollView"] && [self.scrollViewDelegate respondsToSelector:aSelector]) {
        return self.scrollViewDelegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
