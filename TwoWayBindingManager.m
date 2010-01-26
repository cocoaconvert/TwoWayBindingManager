//
// TwoWayBindingManager.m
//
// Latest version at: 
//   http://github.com/cocoaconvert/TwoWayBindingManager
//
// From the article: 
//   http://cocoaconvert.net/2009/05/31/two-way-data-binding-in-cocoa/
//
// Copyright 2009 Department of Behavior and Logic, Inc.
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

#import "TwoWayBindingManager.h"

#define kObservableController @"observableController"
#define kKeyPath @"keyPath"

@implementation TwoWayBindingManager

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	NSDictionary* bindingInfo = [_twoWayBindings valueForKey:keyPath];
	if(bindingInfo != nil)
	{
		id value = [_object valueForKeyPath:keyPath];
		NSString* valueTransformerName = [bindingInfo valueForKey:NSValueTransformerNameBindingOption];
		if(valueTransformerName != nil)
			value = [[NSValueTransformer valueTransformerForName:valueTransformerName] reverseTransformedValue:value];
		id observableController = [bindingInfo valueForKey:kObservableController];
		NSString* observableKeyPath = [bindingInfo valueForKey:kKeyPath];
		if(![[observableController valueForKey:observableKeyPath] isEqual:value])
			[observableController setValue:value forKeyPath:observableKeyPath];			
	}
}

- (void)bind:(NSString *)bindingName toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	id wantsTwoWayBinding = [options valueForKey:kWantsTwoWayBinding];
	if(wantsTwoWayBinding != nil && [wantsTwoWayBinding boolValue])
	{
		[_twoWayBindings setObject:[NSDictionary dictionaryWithObjectsAndKeys:
									observableController, kObservableController, 
									keyPath, kKeyPath, 
									[options objectForKey:NSValueTransformerNameBindingOption], NSValueTransformerNameBindingOption, nil] forKey:bindingName];
		[_object addObserver:self 
			   forKeyPath:bindingName
				  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
				  context:nil];
	}	
}

- (void)unbind:(NSString*)bindingName
{
	if([_twoWayBindings objectForKey:bindingName] != nil)
	{
		[_object removeObserver:self forKeyPath:bindingName];
		[_twoWayBindings removeObjectForKey:bindingName];
	}	
}

- (id)initWithObject:(id)object
{
	if([super init] == nil)
		return nil;
	
	_object = object;
	_twoWayBindings = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)dispose
{
	for(NSString* bindingName in [_twoWayBindings allKeys])
		[_object removeObserver:self forKeyPath:bindingName];
	_object = nil;
	_twoWayBindings = nil;
}

@end
