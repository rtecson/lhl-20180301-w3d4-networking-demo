//
//  ViewController.m
//  w3d4-demo
//
//  Created by Roland on 2018-03-01.
//  Copyright © 2018 MoozX Internet Ventures. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)makeNetworkCallButtonTapped:(UIButton *)sender {
    [self makeNetworkRequest];
}

- (void)makeNetworkRequest {
    self.label.text = @"Retrieving data...";
    
    // Creates a URL object from a string
    NSString *urlString = @"https://swapi.co/api/people";
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Creates a data task for my URL, but nothing happens right away, 2-step process, see [dataTask resume] below
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // This code is executed when the URL request is completed, after the [dataTask resume] line below. This code block is in the background thread
        
        if (error != nil) {
            // Do complex error processing here
            // We return here so that we don't continue processing the rest of the block, i.e. no point in parsing the returned data
            return;
        }

        // This line says to execute the following block in the main queue (dispatch_get_main_queue()), and the async means to kick it off now and resume execution in the line following this code block
        dispatch_async(dispatch_get_main_queue(), ^{
            // The following line will be executed in the main thread
            // It needs to be on the main thread because we're updating a UI element (the UILabel
            self.label.text = @"Data retrieved, parsing now...";
        });
        
        // This line is executed right after the above code block is queued up
        // So let's parse the retrieved data
        [self parseResponseData:data];
    }];
    
    // Execute ("start") the task in a background thread, we don't specify which thread, the task knows it'll be a background thread
    // This executes before the code in the completion block
    [dataTask resume];
}

- (void)parseResponseData:(NSData *)data {
    // Convert NSData object to a JSON object. It's an "id" type because it can either be an NSArray or an NSDictionary
    NSError *error = nil;   // Declare a pointer to an NSError here, the following call will change this pointer to point to a valid NSError object if an error occurs
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // Check for error
    if (error != nil) {
        // Error in parsing NSData
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = @"Error!";
        });
        
        // Do complex error processing here
        return;
    }
    
    // Confirm that JSON object is a dictionary
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        
        // We're done processing, go back to the main loop
        dispatch_async(dispatch_get_main_queue(), ^{
            // Back in the main loop
            self.label.text = @"Completed parsing!";
            NSLog(@"Retrieved dictionary: %@", jsonDict);
        });
    }
}


@end
