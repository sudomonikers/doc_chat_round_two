def clean_string(input_string):
    # Remove \n and extra whitespace
    cleaned_string = " ".join(input_string.split())
    return cleaned_string

def split_into_overlapping_chunks(input_string, chunk_length=200, overlap_size=40):
    cleaned_string = clean_string(input_string)
    chunks = []
    start = 0
    end = chunk_length
    
    while start < len(cleaned_string):
        chunk = cleaned_string[start:end]
        chunks.append(chunk)
        start += overlap_size
        end = start + chunk_length

    return chunks

if __name__ == "__main__":
    #example usage
    print(split_into_overlapping_chunks("lorem ipsum dolor sit amet, \n\nconsectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."))