function rotatedArray = rotateDimension(myArray, dimToRotate)
    % Determine the number of dimensions in the input array
    numDims = ndims(myArray);
    % Generate the original order of dimensions
    originalOrder = 1:numDims;
    % Generate the new order for permutation where the specified dimension comes first
    newOrder = [dimToRotate, setdiff(originalOrder, dimToRotate)];
    % Permute the array so that the specified dimension comes first
    permutedArray = permute(myArray, newOrder);
    % Apply rotation on the now-first dimension
    rotatedArrayFirstDim = fliplr(permutedArray, 1); % This is an example operation
    % Permute back to the original dimension order
    % To permute back, we need the order that reverses the previous permutation
    [~, reverseOrder] = sort(newOrder);
    rotatedArray = ipermute(rotatedArrayFirstDim, reverseOrder);
end
